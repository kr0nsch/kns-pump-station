#!/usr/bin/env python3
"""Приложение имитации КНС-1 в пользовательском рантайме CODESYS Control Win (DESIGN, разделы 14.3 и 16).

    python tools_project/codesys/sim.py start [--no-import] [--need-min N] [--restart-runtime]
    python tools_project/codesys/sim.py reset warm|cold
    python tools_project/codesys/sim.py pki [--no-restart]
    python tools_project/codesys/sim.py stop

``start``: ``cds.py import`` (проект режима normal, объект Persistent Variables), символьная конфигурация сборки
``sim`` (``symbol_config.py --build sim``), рантайм (запуск или перезапуск, если до конца двухчасового демо-режима
меньше ``--need-min`` минут), сертификаты OPC UA (``pki``), загрузка и «Старт» приложения (скрипт CODESYS
``sim_cds.py``), проверка входа по OPC UA. Приложение остаётся в работе — к нему подключаются сценарии ПМИ
(``PMI_LIVE=1 python -m pytest scenarios/test_pmi.py``).

``reset``: тёплый или холодный сброс и «Старт» без загрузки (тот же скрипт CODESYS; им пользуется исполнитель
сценариев OPC UA для шагов ``reset``). ``pki``: сертификат OPC UA-сервера и доверие клиенту сценариев
(``opcua_pki.py``); при изменениях — перезапуск рантайма, иначе он их не увидит. ``stop``: остановка процесса
рантайма (приложение и сервер OPC UA — вместе с ним).

Учётные данные — тот же файл, что у ``cds.py`` (``CODESYS_RUNTIME_CREDENTIALS``); они не печатаются.
Коды выхода: 0 — успех, 1 — шаг не выполнен, 2 — неверные аргументы, 3 и выше — как у ``cds.py``.
"""

from __future__ import annotations

import argparse
import contextlib
import subprocess
import sys
import time
from collections.abc import Sequence
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
TOOLS_CODESYS = ROOT / "tools" / "codesys"
SCENARIOS = ROOT / "scenarios"
HERE = Path(__file__).resolve().parent
sys.path[:0] = [str(TOOLS_CODESYS), str(SCENARIOS), str(HERE)]

import opcua_pki as P  # noqa: E402
from cdshost import cli  # noqa: E402

SCRIPT = HERE / "sim_cds.py"
PROBE = ["GVL_Sim.xSimulation", "GVL_Sim.xIoReady", "GVL_Station.stStationSts.eMode"]
OPCUA_URL = "opc.tcp://localhost:4840"
OPCUA_WAIT_S = 30.0


def _run(cmd: Sequence[str]) -> int:
    print(f"[sim] {' '.join(cmd[1:])}", flush=True)
    return subprocess.run(cmd, cwd=str(ROOT), check=False).returncode


def _job(settings: cli.Settings, op: str, **extra: Any) -> dict[str, Any]:
    step = cli.test_step(settings, settings.project_path(False))
    job: dict[str, Any] = {
        "tools_codesys": str(TOOLS_CODESYS),
        "op": op,
        "project": str(settings.project_path(False)),
        "credentials": step["credentials"],
        "runtime": step["runtime"],
        "probe": PROBE,
        "log": str(ROOT / "build" / f"sim-{op}.log"),
    }
    job.update(extra)
    return job


def client_certificate() -> bytes:
    """Сертификат клиента сценариев (создаётся при первом вызове, как у исполнителя OPC UA)."""
    from kns_scenarios.backend_opcua import CLIENT_CERT_DIR, ensure_client_certificate

    cert, _ = ensure_client_certificate(CLIENT_CERT_DIR.expanduser())
    return cert.read_bytes()


def pki_dir(settings: cli.Settings) -> Path:
    candidates = P.pki_candidates(
        settings.path("runtime.exe", must_exist=True), settings.path("runtime.work_dir"), P.local_appdata()
    )
    found = P.find_pki(candidates)
    if found is None:
        raise cli.CdsError(
            "не найдено хранилище сертификатов рантайма (.pki): запустите рантайм хотя бы раз "
            f"(cds.py runtime start); искали: {', '.join(str(c) for c in candidates)}",
            cli.EXIT_ENV,
        )
    return found


def do_pki(settings: cli.Settings, restart: bool) -> bool:
    """Сертификаты OPC UA; при изменениях и ``restart`` — перезапуск рантайма. Возвращает «были изменения»."""
    pki = pki_dir(settings)
    change = P.provision(pki, client_certificate())
    if change.server_cert:
        print(f"[sim] создан сертификат OPC UA-сервера: {pki / 'own' / 'cert' / change.server_cert}")
    if change.trusted_client:
        print(f"[sim] сертификат клиента сценариев — в доверенных: {pki / 'trusted' / 'cert' / change.trusted_client}")
    for name in change.removed_rejected:
        print(f"[sim] удалён из отклонённых: {name}")
    if not change.changed:
        print(f"[sim] хранилище {pki}: сертификат сервера есть, клиент в доверенных")
    if change.changed and restart and cli.runtime_status(settings)["running"]:
        print("[sim] перезапуск рантайма: хранилище сертификатов читается при запуске")
        cli.runtime_stop(settings)
        cli.runtime_start(settings)
    return change.changed


def wait_opcua(timeout_s: float = OPCUA_WAIT_S) -> dict[str, Any]:
    """Вход по OPC UA (Basic256Sha256, имя и пароль) и чтение признака имитации."""
    from kns_scenarios.backend_opcua import OpcUaClient
    from kns_scenarios.credentials import load_credentials

    deadline = time.monotonic() + timeout_s
    last = ""
    while time.monotonic() < deadline:
        client = OpcUaClient(OPCUA_URL, credentials=load_credentials())
        try:
            client.connect()
            values = client.read(PROBE)
            return {"device": client.device, "namespace": client.namespace, **dict(zip(PROBE, values, strict=True))}
        except Exception as exc:  # сервер ещё поднимается после «Старт» или перезапуска
            last = f"{type(exc).__name__}: {exc}"
        finally:
            with contextlib.suppress(Exception):
                client.close()
        time.sleep(2.0)
    raise cli.CdsError(f"OPC UA: вход не удался за {timeout_s:.0f} с ({last})", cli.EXIT_FAILED)


def _online(settings: cli.Settings, op: str, label: str, **extra: Any) -> dict[str, Any]:
    with cli.runtime_lock(settings, f"sim {label}"):
        result = cli.run_codesys(settings, str(SCRIPT), _job(settings, op, **extra), f"sim-{label}")
    if not result.get("ok"):
        raise cli.CdsError(f"{label}: {result.get('error', 'CODESYS не выполнил операцию')}", cli.EXIT_FAILED)
    print(f"[sim] {label}: состояние {result.get('state')}; {result.get('probe')}")
    return result


def cmd_start(settings: cli.Settings, args: argparse.Namespace) -> int:
    py = sys.executable
    if not args.no_import:
        if _run([py, str(TOOLS_CODESYS / "cds.py"), "import"]) != 0:
            return 1
        if _run([py, str(HERE / "symbol_config.py"), "--build", "sim"]) != 0:
            return 1
    status = cli.runtime_status(settings)
    restart = args.restart_runtime or (status["running"] and (status.get("demo_left_min") or 0) < args.need_min)
    if restart:
        print(f"[sim] перезапуск рантайма (до конца демо-режима {status.get('demo_left_min')} мин)")
    cli.ensure_runtime(settings, restart=restart)
    do_pki(settings, restart=True)
    _online(settings, "start", "start")
    print(f"[sim] OPC UA: {wait_opcua()}")
    return 0


def cmd_reset(settings: cli.Settings, args: argparse.Namespace) -> int:
    _online(settings, "reset", f"reset-{args.kind}", reset=args.kind)
    return 0


def cmd_pki(settings: cli.Settings, args: argparse.Namespace) -> int:
    do_pki(settings, restart=not args.no_restart)
    return 0


def cmd_stop(settings: cli.Settings, args: argparse.Namespace) -> int:
    with cli.runtime_lock(settings, "sim stop"):
        stopped = cli.runtime_stop(settings)
    print(f"[sim] остановлено: {stopped or 'нечего останавливать'}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="sim.py", description="Приложение имитации КНС-1 в рантайме CODESYS")
    sub = parser.add_subparsers(dest="command", required=True)
    p = sub.add_parser("start", help="импорт, символы, рантайм, сертификаты OPC UA, загрузка и «Старт»")
    p.add_argument("--no-import", action="store_true", help="проект уже собран: без import и symbol_config")
    p.add_argument(
        "--need-min", type=float, default=0.0, help="перезапустить рантайм, если демо-режиму осталось меньше"
    )
    p.add_argument("--restart-runtime", action="store_true", help="перезапустить рантайм перед загрузкой")
    p.set_defaults(func=cmd_start)
    p = sub.add_parser("reset", help="сброс приложения и «Старт» без загрузки")
    p.add_argument("kind", choices=("warm", "cold"))
    p.set_defaults(func=cmd_reset)
    p = sub.add_parser("pki", help="сертификат OPC UA-сервера и доверие клиенту сценариев")
    p.add_argument("--no-restart", action="store_true", help="не перезапускать рантайм после изменений")
    p.set_defaults(func=cmd_pki)
    p = sub.add_parser("stop", help="остановить процесс рантайма")
    p.set_defaults(func=cmd_stop)
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    for stream in (sys.stdout, sys.stderr):
        reconfigure = getattr(stream, "reconfigure", None)
        if reconfigure is not None:
            reconfigure(encoding="utf-8", errors="replace")
    args = build_parser().parse_args(argv)
    try:
        code: int = args.func(cli.make_settings(ROOT), args)
        return code
    except cli.CdsError as exc:
        print(f"[sim] ОШИБКА: {exc}", file=sys.stderr)
        return exc.code


if __name__ == "__main__":
    sys.exit(main())
