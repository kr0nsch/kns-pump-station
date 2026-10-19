# -*- coding: utf-8 -*-
"""Символьная конфигурация OPC UA в приложении проекта (CODESYS Scripting, IronPython 2.7).

Скрипт выполняет CODESYS без окна, его запускает ``tools_project/codesys/symbol_config.py`` (вручную не
запускается). Основа — проверенный скрипт проекта 06 портфолио (docs/MANUAL_STEPS.md, раздел 10.2):
``application.create_symbol_config(False, True, <OptimizedOutputOffsetCalculator>)``, доступ —
``configured_access`` переменных из ``get_all_signatures(True)``. Задание — JSON, путь — в ``CDS_JOB``::

    {
      "tools_codesys": "<repo>/tools/codesys",
      "project": "<путь>.project",
      "rules": [{"gvl": "GVL_IO", "vars": ["*"], "access": "Read"}, ...],   правила одной сборки
      "result": "<путь>.json"
    }

Первое подходящее правило выигрывает; переменная без правила или с access = null — без доступа (None).
Доступ меняется, только если отличается (идемпотентно). Затем сборка и генерация кода: файл символов
``<проект>.Device.Application.xml`` пишет генерация кода. Синтаксис — общее подмножество Python 2.7 и 3.x.
"""

from __future__ import absolute_import, print_function, unicode_literals

import fnmatch
import io
import json
import os
import sys
import traceback

JOB_ENV = 'CDS_JOB'
# OptimizedOutputOffsetCalculator: оптимизированная раскладка для клиентов (проверено в проекте 06)
OPTIMIZED_LAYOUT_GUID = '{0141eb75-141b-4ea1-9a8c-75f952b22a6c}'


def load_job():
    path = os.environ.get(JOB_ENV)
    if not path or not os.path.isfile(path):
        raise RuntimeError('нет файла задания (переменная %s): запускайте через tools_project/codesys/symbol_config.py' % JOB_ENV)
    with io.open(path, encoding='utf-8') as handle:
        return json.loads(handle.read())


JOB = load_job()
sys.path.insert(0, JOB['tools_codesys'])

import cds_common as C  # noqa: E402

SE = C.api()


def symbol_access_enum():
    """Перечисление SymbolAccess среды CODESYS: модуль scriptengine или глобальное имя скрипта (проект 06)."""
    enum = getattr(SE, 'SymbolAccess', None)
    if enum is None:
        enum = globals().get('SymbolAccess')
    if enum is None:
        raise RuntimeError('нет перечисления SymbolAccess в среде CODESYS Scripting')
    return enum


ACCESS = symbol_access_enum()


def access_value(name):
    """'Read' / 'ReadWrite' / None → значение SymbolAccess (имя None — ключевое слово Python, поэтому getattr)."""
    return getattr(ACCESS, 'None' if name is None else name)


def access_name(value):
    text = C._text(value)
    return text.split('.')[-1]


def wanted(rules, gvl, var):
    """Доступ по правилам: первое подходящее правило; нет правила — None."""
    for rule in rules:
        if rule['gvl'].lower() != gvl.lower():
            continue
        for pattern in rule['vars']:
            if fnmatch.fnmatchcase(var.lower(), pattern.lower()):
                return rule['access']
    return None


def find_symbol_config(app):
    for child in C.children(app):
        try:
            if child.is_symbol_config:
                return child
        except Exception:
            pass
    return None


def main():
    result = {'ok': False, 'created': False, 'changed': 0, 'counts': {}, 'messages': []}
    code = 1
    proj = None
    try:
        from System import Guid  # .NET: только в IronPython (CODESYS)

        path = JOB['project']
        rules = JOB['rules']
        C.check_project_lock(path)
        C.remove_precompile_cache(path)
        proj = SE.projects.open(path, primary=True)
        C.load_object_tree(proj)
        app = C.application(proj)
        sc = find_symbol_config(app)
        if sc is None:
            # комментарии в XML — нет, возможности OPC UA — да, раскладка — оптимизированная
            sc = app.create_symbol_config(False, True, Guid(OPTIMIZED_LAYOUT_GUID))
            result['created'] = True
        counts = {}
        for sig in sc.get_all_signatures(True):   # True — собрать приложение
            gvl = C._text(sig.full_qualified_name).split('.')[-1]
            for var in sig.variables:
                name = C._text(var.name)
                access = wanted(rules, gvl, name)
                target = access_value(access)
                if var.configured_access != target:
                    var.configured_access = target
                    result['changed'] += 1
                if access is not None:
                    counts.setdefault(gvl, {}).setdefault(access, 0)
                    counts[gvl][access] += 1
        result['counts'] = counts
        app.build()
        app.generate_code()
        proj.save()
        result['ok'] = True
        code = 0
    except Exception:
        result['error'] = C._text(traceback.format_exc())
    finally:
        if proj is not None:
            try:
                proj.close()
            except Exception:
                pass
        result['exit_code'] = code
        C.write_json(JOB['result'], result)
    sys.exit(code)


main()
