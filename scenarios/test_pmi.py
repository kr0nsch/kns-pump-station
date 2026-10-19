"""Сценарии ПМИ на рантайме CODESYS Control Win через OPC UA (маркер plc; запуск — ``PMI_LIVE=1``, адрес
сервера — ``PMI_OPCUA_URL``, по умолчанию ``opc.tcp://localhost:4840``).

Нужны: приложение имитации собрано, загружено и запущено, сертификат OPC UA-сервера и доверие клиенту — всё это
делает ``python tools_project/codesys/sim.py start`` (DESIGN, раздел 16, шаг 5); учётные данные
``credentials.json``. Шаги ``reset`` (PMI-10, PMI-35) выполняет ``sim.py reset`` (переменная ``PMI_RESET``: ``sim``
по умолчанию при заданном ``CODESYS_EXE``, ``none`` — шаг «не проверялось»). Итог — отчёт
``build/pmi-results.json`` и ``.md`` (заготовка протокола 07).

Регрессионные сценарии ``scenarios/regression/*.toml`` — не пункты 06_PMI: дефекты, найденные вне программы (тот же
формат и исполнитель); отчёт — ``build/regression-results.json`` и ``.md``. Только они: ``-k regression``.
"""

from __future__ import annotations

import os
import subprocess
import sys
from collections.abc import Callable, Iterator
from pathlib import Path

import pytest

from kns_scenarios import report
from kns_scenarios.alarms import AlarmView, load_alarm_list
from kns_scenarios.backend_opcua import OpcUaClient
from kns_scenarios.client import ResetKind
from kns_scenarios.context import TIME_SCALE, ScenarioContext
from kns_scenarios.credentials import load_credentials
from kns_scenarios.enums import ENUMS
from kns_scenarios.journal import EventFeed
from kns_scenarios.scenario import FAIL, Runner, ScenarioResult, load_scenario

HERE = Path(__file__).resolve().parent
BUILD = HERE.parent / "build"
FILES = sorted((HERE / "pmi").glob("PMI-*.toml")) or sorted((HERE / "examples").glob("PMI-*.toml"))
REGRESSION_FILES = sorted((HERE / "regression").glob("*.toml"))
RESULTS: list[ScenarioResult] = []
REGRESSION_RESULTS: list[ScenarioResult] = []
LIVE = os.environ.get("PMI_LIVE") == "1"
URL = os.environ.get("PMI_OPCUA_URL", "opc.tcp://localhost:4840")
SIM_TOOL = HERE.parent / "tools_project" / "codesys" / "sim.py"
# сброс приложения для шагов reset (PMI-10, PMI-35): sim — скрипт CODESYS (нужен CODESYS_EXE), none — без сброса
RESET = os.environ.get("PMI_RESET", "sim" if os.environ.get("CODESYS_EXE") else "none")


def sim_resetter(client: list[OpcUaClient]) -> Callable[[ResetKind], None]:
    """Сброс через ``sim.py reset``: на время запуска CODESYS (десятки секунд) контур переводится на k = 1, чтобы
    процесс не ушёл вперёд; после сброса ускорение и параметры модели задаёт сценарий."""

    def reset(kind: ResetKind) -> None:
        client[0].write({TIME_SCALE: 1.0})
        subprocess.run([sys.executable, str(SIM_TOOL), "reset", kind], check=True, timeout=600)

    return reset


@pytest.fixture(scope="module")
def plc() -> Iterator[OpcUaClient]:
    holder: list[OpcUaClient] = []
    client = OpcUaClient(URL, credentials=load_credentials(), resetter=sim_resetter(holder) if RESET == "sim" else None)
    holder.append(client)
    client.connect()
    try:
        yield client
    finally:
        client.close()
        if RESULTS:
            report.write_reports(RESULTS, BUILD)
        if REGRESSION_RESULTS:
            report.write_reports(REGRESSION_RESULTS, BUILD, stem="regression-results")


@pytest.mark.plc
@pytest.mark.skipif(not LIVE, reason="сценарий на рантайме: PMI_LIVE=1 (DESIGN, раздел 14.3)")
@pytest.mark.parametrize("path", FILES, ids=[f.stem for f in FILES])
def test_pmi(plc: OpcUaClient, path: Path) -> None:
    run_scenario(plc, path, RESULTS)


@pytest.mark.plc
@pytest.mark.skipif(not LIVE, reason="сценарий на рантайме: PMI_LIVE=1 (DESIGN, раздел 14.3)")
@pytest.mark.parametrize("path", REGRESSION_FILES, ids=[f"regression-{f.stem}" for f in REGRESSION_FILES])
def test_regression(plc: OpcUaClient, path: Path) -> None:
    run_scenario(plc, path, REGRESSION_RESULTS)


def run_scenario(plc: OpcUaClient, path: Path, results: list[ScenarioResult]) -> None:
    ctx = ScenarioContext(plc, enums=ENUMS)
    runner = Runner(ctx, "opcua", alarms=AlarmView(plc, load_alarm_list(), ENUMS), feed=EventFeed(plc))
    result = runner.run(load_scenario(path))
    results.append(result)
    assert result.verdict != FAIL, result.error or [c for c in result.checks if c.ok is False]
