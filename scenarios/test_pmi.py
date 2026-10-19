"""Сценарии ПМИ на рантайме CODESYS Control Win через OPC UA (маркер plc; запуск — ``PMI_LIVE=1``, адрес
сервера — ``PMI_OPCUA_URL``, по умолчанию ``opc.tcp://localhost:4840``).

Нужны: приложение имитации собрано и загружено (``cds.py import``, ``codesys_pvl.py``, символьная
конфигурация ``tools_project/codesys/symbol_config.py``, загрузка и «Старт»), сертификат OPC UA-сервера и
доверие клиенту (ручной шаг 5 DESIGN, раздел 16), учётные данные ``credentials.json``. Итог — отчёт
``build/pmi-results.json`` и ``.md`` (заготовка протокола 07).
"""

from __future__ import annotations

import os
from collections.abc import Iterator
from pathlib import Path

import pytest

from kns_scenarios import report
from kns_scenarios.alarms import AlarmView, load_alarm_list
from kns_scenarios.backend_opcua import OpcUaClient
from kns_scenarios.context import ScenarioContext
from kns_scenarios.credentials import load_credentials
from kns_scenarios.enums import ENUMS
from kns_scenarios.journal import EventFeed
from kns_scenarios.scenario import FAIL, Runner, ScenarioResult, load_scenario

HERE = Path(__file__).resolve().parent
BUILD = HERE.parent / "build"
FILES = sorted((HERE / "pmi").glob("PMI-*.toml")) or sorted((HERE / "examples").glob("PMI-*.toml"))
RESULTS: list[ScenarioResult] = []
LIVE = os.environ.get("PMI_LIVE") == "1"
URL = os.environ.get("PMI_OPCUA_URL", "opc.tcp://localhost:4840")


@pytest.fixture(scope="module")
def plc() -> Iterator[OpcUaClient]:
    client = OpcUaClient(URL, credentials=load_credentials())
    client.connect()
    try:
        yield client
    finally:
        client.close()
        if RESULTS:
            report.write_reports(RESULTS, BUILD)


@pytest.mark.plc
@pytest.mark.skipif(not LIVE, reason="сценарий на рантайме: PMI_LIVE=1 (DESIGN, раздел 14.3)")
@pytest.mark.parametrize("path", FILES, ids=[f.stem for f in FILES])
def test_pmi(plc: OpcUaClient, path: Path) -> None:
    ctx = ScenarioContext(plc, enums=ENUMS)
    runner = Runner(ctx, "opcua", alarms=AlarmView(plc, load_alarm_list(), ENUMS), feed=EventFeed(plc))
    result = runner.run(load_scenario(path))
    RESULTS.append(result)
    assert result.verdict != FAIL, result.error or [c for c in result.checks if c.ok is False]
