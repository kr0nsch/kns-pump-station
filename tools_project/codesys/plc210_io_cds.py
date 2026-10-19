# -*- coding: utf-8 -*-
"""Дерево устройств сборки ОВЕН ПЛК210 в проекте (CODESYS Scripting, IronPython 2.7).

Скрипт выполняет CODESYS без окна, его запускает ``tools_project/codesys/plc210_io.py apply`` (вручную не
запускается). Задание — JSON (путь в ``CDS_JOB``) готовит ``plc210_io.py`` из перечня сигналов и
``targets/plc210/hardware.json``::

    {"project": ..., "tools_codesys": ..., "device": {...}, "slot": {...},
     "mappings": [{"device": "LeftSide", "param": 5001, "element": "FDI_1", "variable": "Application.GVL_IO.xLS102"}],
     "parameters": [{"device": "RightSide", "param": 301, "value": "11"}],
     "serial": [{"name": "RS485_1", "com_port": 5, ..., "slaves": [{"name": "P101", "address": 1, "channels_xml": ...}]}],
     "ethernet": {"name": "Ethernet", "master": "MB_TCP_Master", "slaves": [...]},
     "generate_code": true, "result": ...}

Порядок: проверка устройства проекта → модуль-слот модификации (plug) → линии RS-485 и Ethernet пересоздаются
(дерево Modbus — только из задания, повторный запуск даёт тот же результат) → каналы слейвов: выгрузка слейва в
PLCopenXML, вставка параметров каналов перед ConfigVersion, удаление и импорт обратно → привязки встроенного
ввода-вывода и параметры каналов → проверка: у слейвов столько каналов и привязок, сколько в задании →
сохранение → сборка (rebuild) и «Генерировать код», сообщения — как у ``cds.py build``.
Синтаксис — общее подмножество Python 2.7 и 3.x.
"""

from __future__ import absolute_import, print_function, unicode_literals

import io
import json
import os
import sys
import traceback

JOB_ENV = 'CDS_JOB'
CONFIG_VERSION_ID = 1879052288
CHANNEL_TYPE = 'type="localTypes:CHANNEL_PACKED"'
DEV_COM = (92, '0000 0001', '3.5.16.0')          # Modbus COM
DEV_COM_MASTER = (90, '0000 0002', '3.5.17.0')   # Modbus Master, COM Port
DEV_COM_SLAVE = (91, '0000 0001', '3.5.16.0')    # Modbus Slave, COM Port
DEV_ETHERNET = (110, '0000 0002', '3.5.17.0')    # Ethernet
DEV_TCP_MASTER = (88, '0000 0003', '3.5.17.0')   # Modbus TCP Master
DEV_TCP_SLAVE = (89, '0000 0005', '3.5.16.0')    # Modbus TCP Slave
# Параметры коннекторов (описания устройств Modbus CODESYS 3.5.17.30)
P_COM_BAUD, P_COM_PARITY, P_COM_DATA, P_COM_STOP, P_COM_PORT = 9200, 9202, 9203, 9204, 9206
P_MASTER_TIMEOUT, P_MASTER_AUTORESTART = 9001, 9005
P_SLAVE_ADDRESS, P_SLAVE_TIMEOUT = 9100, 9101
P_TCP_UNIT, P_TCP_IP, P_TCP_PORT = 9100, 9102, 9103


def load_job():
    path = os.environ.get(JOB_ENV)
    if not path or not os.path.isfile(path):
        raise RuntimeError('нет файла задания (переменная %s): запускайте через tools_project/codesys/plc210_io.py' % JOB_ENV)
    with io.open(path, encoding='utf-8') as handle:
        return json.loads(handle.read())


JOB = load_job()
sys.path.insert(0, JOB['tools_codesys'])

import build as B  # noqa: E402
import cds_common as C  # noqa: E402

SE = C.api()
LOG = []


def note(text):
    LOG.append(text)


def child(parent, name):
    lower = name.lower()
    for obj in C.children(parent):
        if C.obj_name(obj).lower() == lower:
            return obj
    return None


def find_deep(parent, name):
    for obj in C.children(parent):
        if C.obj_name(obj) == name:
            return obj
        found = find_deep(obj, name)
        if found is not None:
            return found
    return None


def host_param(dev, pid):
    for conn in dev.connectors:
        try:
            params = conn.host_parameters
        except Exception:
            continue
        for p in params:
            if p.id == pid:
                return p
    raise RuntimeError('у устройства %s нет параметра %d' % (C.obj_name(dev), pid))


def set_param(dev, pid, value):
    host_param(dev, pid).value = '%s' % value


def add_device(parent, name, ident):
    parent.add(name, ident[0], ident[1], ident[2])
    dev = child(parent, name)
    if dev is None:
        raise RuntimeError('устройство %s не добавлено под %s' % (name, C.obj_name(parent)))
    return dev


def check_device(proj):
    want = JOB['device']
    dev = C.find_device(proj)
    if dev is None:
        raise RuntimeError('в проекте нет устройства')
    ident = dev.get_device_identification()
    have = (int(ident.type), C._text(ident.id), C._text(ident.version))
    if have != (int(want['type']), want['id'], want['version']):
        raise RuntimeError('устройство проекта %s, ожидалось %s / %s / %s (targets/plc210/hardware.json)'
                           % (have, want['type'], want['id'], want['version']))
    return dev


def plug_slot(dev):
    slot = JOB['slot']
    for obj in C.children(dev):
        try:
            ident = obj.get_device_identification()
        except Exception:
            continue
        if int(ident.type) != int(slot['type']):
            continue
        if C._text(ident.id) == slot['id'] and C._text(ident.version) == slot['version']:
            note('модуль-слот %s уже на месте' % C.obj_name(obj))
            return
        old = C.obj_name(obj)
        obj.plug(slot['name'], int(slot['type']), slot['id'], slot['version'])
        note('модуль-слот %s заменён на %s (%s %s)' % (old, slot['name'], slot['id'], slot['version']))
        return
    raise RuntimeError('у устройства нет модуля-слота типа %s' % slot['type'])


def slave_with_channels(proj, master, spec, ident, setup):
    """Слейв: добавить, задать параметры, вставить каналы через PLCopenXML и вернуть устройство."""
    slave = add_device(master, spec['name'], ident)
    for pid, value in setup:
        set_param(slave, pid, value)
    xml = proj.export_xml([slave], None, None, True)
    marker = '<Parameter ParameterId="%d"' % CONFIG_VERSION_ID
    if xml.count(marker) != 1 or CHANNEL_TYPE in xml:
        raise RuntimeError('слейв %s: неожиданная выгрузка XML (ConfigVersion: %d)' % (spec['name'], xml.count(marker)))
    xml = xml.replace(marker, spec['channels_xml'] + marker)
    slave.remove()
    master.import_xml(xml)
    slave = child(master, spec['name'])
    if slave is None:
        raise RuntimeError('слейв %s не импортирован обратно' % spec['name'])
    channels, mapped = slave_stats(slave)
    want_channels = len(spec['channels'])
    want_mapped = sum(int(c['mapped']) for c in spec['channels'])
    if channels != want_channels or mapped != want_mapped:
        raise RuntimeError('слейв %s: каналов %d (ожидалось %d), привязок %d (ожидалось %d)'
                           % (spec['name'], channels, want_channels, mapped, want_mapped))
    note('слейв %s: каналов %d, привязок %d' % (spec['name'], channels, mapped))
    return slave


def _walk_mapped(element, acc):
    try:
        if element.is_mappable_io and element.io_mapping.variable:
            acc.append(C._text(element.io_mapping.variable))
    except Exception:
        pass
    try:
        if element.has_sub_elements:
            for sub in element:
                _walk_mapped(sub, acc)
    except Exception:
        pass


def slave_stats(slave):
    channels = 0
    mapped = []
    for conn in slave.connectors:
        try:
            params = conn.host_parameters
        except Exception:
            continue
        for p in params:
            if p.id >= (1 << 24) and (p.id >> 16) & 0xFF == 0x10:
                channels += 1
            _walk_mapped(p, mapped)
    return channels, len(mapped)


def build_serial(proj, dev):
    for line in JOB.get('serial') or []:
        com = add_device(dev, line['name'], DEV_COM)
        set_param(com, P_COM_PORT, line['com_port'])
        set_param(com, P_COM_BAUD, line['baudrate'])
        set_param(com, P_COM_PARITY, "'%s'" % line['parity'])
        set_param(com, P_COM_DATA, line['data_bits'])
        set_param(com, P_COM_STOP, line['stop_bits'])
        master = add_device(com, line['master'], DEV_COM_MASTER)
        set_param(master, P_MASTER_TIMEOUT, line['response_timeout_ms'])
        set_param(master, P_MASTER_AUTORESTART, 'TRUE' if line['auto_restart'] else 'FALSE')
        note('%s: COM%s, %s бит/с, %s; мастер %s' % (line['name'], line['com_port'], line['baudrate'], line['parity'], line['master']))
        for spec in line['slaves']:
            slave_with_channels(proj, master, spec, DEV_COM_SLAVE,
                                [(P_SLAVE_ADDRESS, spec['address']), (P_SLAVE_TIMEOUT, spec['timeout_ms'])])


def build_ethernet(proj, dev):
    eth_spec = JOB.get('ethernet') or {}
    if not eth_spec.get('slaves'):
        return
    eth = add_device(dev, eth_spec['name'], DEV_ETHERNET)
    master = add_device(eth, eth_spec['master'], DEV_TCP_MASTER)
    note('%s: мастер %s' % (eth_spec['name'], eth_spec['master']))
    for spec in eth_spec['slaves']:
        slave_with_channels(proj, master, spec, DEV_TCP_SLAVE,
                            [(P_TCP_UNIT, spec['unit_id']), (P_TCP_IP, spec['ip']), (P_TCP_PORT, spec['port'])])


def remove_generated(dev):
    names = [line['name'] for line in JOB.get('serial') or []]
    if (JOB.get('ethernet') or {}).get('slaves'):
        names.append(JOB['ethernet']['name'])
    for name in names:
        obj = child(dev, name)
        if obj is not None:
            obj.remove()
            note('удалено устройство %s (пересоздаётся из задания)' % name)


def apply_builtin(dev):
    done = 0
    for item in JOB.get('mappings') or []:
        target = find_deep(dev, item['device'])
        if target is None:
            raise RuntimeError('нет устройства %s встроенного ввода-вывода' % item['device'])
        param = host_param(target, int(item['param']))
        element = param
        if item.get('element'):
            element = None
            for sub in param:
                if C._text(sub.identifier) == item['element']:
                    element = sub
                    break
            if element is None:
                raise RuntimeError('%s, параметр %s: нет элемента %s' % (item['device'], item['param'], item['element']))
        element.io_mapping.variable = item['variable']
        done += 1
    for item in JOB.get('parameters') or []:
        target = find_deep(dev, item['device'])
        set_param(target, int(item['param']), item['value'])
    note('встроенный ввод-вывод: привязок %d, параметров %d' % (done, len(JOB.get('parameters') or [])))


def device_tree(obj, depth=0, acc=None):
    """Дерево устройств для отчёта: «  имя [тип id версия]» по уровням."""
    acc = [] if acc is None else acc
    for sub in C.children(obj):
        try:
            if not sub.is_device:
                continue
            ident = sub.get_device_identification()
        except Exception:
            continue
        acc.append('%s%s [%s %s %s]' % ('  ' * depth, C.obj_name(sub), ident.type, C._text(ident.id), C._text(ident.version)))
        device_tree(sub, depth + 1, acc)
    return acc


def compile_step(app, label, action):
    B.clear_messages()
    action()
    records = B.collect_messages()
    summary = B.summarize(records)
    errors = max(summary['errors'], summary['summary_errors'] or 0)
    lines = [B.format_record(r) for r in records if r['severity'] in B.ERROR_SEVERITIES + B.WARNING_SEVERITIES]
    note('%s: ошибок %d, предупреждений %d' % (label, errors, summary['warnings']))
    return {'errors': errors, 'warnings': summary['warnings'], 'summary_line': summary['summary_line'],
            'messages': lines}


def main():
    result = {'ok': False, 'exit_code': 1, 'log': LOG}
    proj = None
    try:
        path = JOB['project']
        C.check_project_lock(path)
        C.remove_precompile_cache(path)
        proj = SE.projects.open(path)
        dev = check_device(proj)
        plug_slot(dev)
        remove_generated(dev)
        build_serial(proj, dev)
        build_ethernet(proj, dev)
        apply_builtin(dev)
        proj.save()
        result['tree'] = {'errors': 0, 'warnings': 0}
        result['device_tree'] = device_tree(proj)
        app = C.application(proj)
        result['build'] = compile_step(app, 'сборка', app.rebuild)
        ok = result['build']['errors'] == 0
        if ok and JOB.get('generate_code'):
            result['generate'] = compile_step(app, 'генерация кода', app.generate_code)
            ok = result['generate']['errors'] == 0
        proj.save()
        result['ok'] = ok
        result['exit_code'] = 0 if ok else 1
        if not ok:
            result['error'] = 'ошибки сборки — см. messages'
    except Exception:
        result['error'] = C._text(traceback.format_exc())
    finally:
        if proj is not None:
            try:
                proj.close()
            except Exception:
                pass
        C.write_json(JOB['result'], result)


main()
