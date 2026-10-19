# -*- coding: utf-8 -*-
"""Приложение имитации в рантайме CODESYS Control Win: загрузка и «Старт», сброс (CODESYS Scripting, IronPython 2.7).

Скрипт выполняет CODESYS без окна, его запускает ``tools_project/codesys/sim.py`` (вручную не запускается).
Онлайн-последовательность — та же, что у ``tools/codesys/run_tests.py`` (шлюз, адрес устройства, учётные данные
из ``credentials.json``, первый пользователь свежего рантайма), но приложение после выхода остаётся в работе:
сценарии ПМИ подключаются к нему по OPC UA. Задание — JSON, путь — в ``CDS_JOB``::

    {
      "tools_codesys": "<repo>/tools/codesys",
      "op": "start" | "reset",
      "project": "<путь>.project",          проект режима normal после import и symbol_config.py
      "credentials": "<путь>/credentials.json",
      "runtime": {...},                     как у шага test cds.py
      "reset": "warm" | "cold",             для op = "reset"
      "probe": ["GVL_Sim.xSimulation", ...], выражения для чтения после «Старт» (в результат)
      "log": "<путь>.log",
      "result": "<путь>.json"
    }

``start``: вход с загрузкой (``OnlineChangeOption.Never``, чужие приложения удаляются), «Старт», чтение ``probe``,
выход. ``reset``: вход без загрузки (приложение в ПЛК должно совпадать с проектом), сброс тёплый или холодный
(``ScriptOnlineApplication.reset``), «Старт», чтение ``probe``, выход. Учётные данные в журнал не пишутся.
Синтаксис — общее подмножество Python 2.7 и 3.x.
"""

from __future__ import absolute_import, print_function, unicode_literals

import io
import json
import os
import sys
import time
import traceback

JOB_ENV = 'CDS_JOB'


def load_job():
    path = os.environ.get(JOB_ENV)
    if not path or not os.path.isfile(path):
        raise RuntimeError('нет файла задания (переменная %s): запускайте через tools_project/codesys/sim.py' % JOB_ENV)
    with io.open(path, encoding='utf-8') as handle:
        return json.loads(handle.read())


JOB = load_job()
sys.path.insert(0, JOB['tools_codesys'])

import cds_common as C  # noqa: E402
import run_tests as RT  # noqa: E402

SE = C.api()


def login_existing(app, creds):
    """Вход без загрузки: приложение в ПЛК — то же, что в проекте (иначе CODESYS отказывает)."""
    SE.online.set_default_credentials(creds['user'], creds['password'])
    oa = SE.online.create_online_application(app)
    oa.login(SE.OnlineChangeOption.Never, False)
    return oa


def wait_running(oa, timeout_s):
    """«Старт» выполнен: состояние приложения run (строка CODESYS содержит 'run')."""
    deadline = time.time() + timeout_s
    state = ''
    while time.time() < deadline:
        state = C._text(oa.application_state)
        if 'run' in state.lower():
            return state
        SE.system.delay(200)
    return state


def main():
    result = {'ok': False, 'op': JOB.get('op'), 'probe': {}}
    code = 1
    oa = None
    log = C.Log(JOB.get('log'))
    ctx = C.Context(JOB)
    try:
        op = JOB['op']
        creds = RT.read_credentials(JOB['credentials'])
        proj, _ = ctx.open_project(JOB['project'], create=False, log=log)
        app = C.application(proj)
        dev = C.find_device(proj)
        if dev is None:
            raise C.StepError('в проекте нет устройства')
        target = RT.setup_gateway(dev, JOB.get('runtime') or {}, log)
        if op == 'start':
            log.info('вход в рантайм и загрузка приложения имитации')
            oa = RT.login(app, dev, creds, target, log)
        elif op == 'reset':
            log.info('вход в рантайм без загрузки')
            oa = login_existing(app, creds)
            kind = JOB.get('reset') or 'warm'
            option = SE.ResetOption.Cold if kind == 'cold' else SE.ResetOption.Warm
            log.info('сброс %s' % kind)
            oa.reset(option)
            result['reset'] = kind
            SE.system.delay(500)
        else:
            raise C.StepError('неизвестная операция %r (start, reset)' % op)
        oa.start()
        result['state'] = wait_running(oa, 20.0)
        log.info('состояние приложения: %s' % result['state'])
        SE.system.delay(int(JOB.get('settle_ms') or 1000))
        reader = RT.Reader(oa, log)
        probe = list(JOB.get('probe') or [])
        if probe:
            values = reader.values(probe)
            for index, expr in enumerate(probe):
                value = values[index] if index < len(values) else None
                result['probe'][expr] = value if isinstance(value, (bool, int, float)) else C._text(value)
        result['ok'] = 'run' in C._text(result['state']).lower()
        code = 0 if result['ok'] else 1
        if not result['ok']:
            result['error'] = 'приложение не перешло в работу: %s' % result['state']
    except Exception:
        result['error'] = C._text(traceback.format_exc())
        log.error(result['error'])
    finally:
        if oa is not None:
            try:
                oa.logout()   # приложение остаётся в работе
                log.info('выход из рантайма, приложение в работе')
            except Exception as exc:
                log.warn('logout: %s' % exc)
        ctx.close()
        result['exit_code'] = code
        C.write_json(JOB['result'], result)
        log.close()
    sys.exit(code)


main()
