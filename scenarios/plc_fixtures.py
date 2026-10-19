"""Фикстуры pytest обвязки сценариев: имитатор OPC UA-сервера CODESYS и клиент к нему.

Не ``conftest.py``: модуль с таким именем уже есть у тестов шаблона (``tools/tests/conftest.py``), и при общем
``pythonpath`` они бы перекрыли друг друга. Тесты импортируют фикстуры явно.
"""

from __future__ import annotations

from collections.abc import Iterator

import pytest

from kns_scenarios.backend_opcua import OpcUaClient
from mock_plc import MockPlc, start_mock_plc


@pytest.fixture(scope="module")
def mock_plc() -> Iterator[MockPlc]:
    plc = start_mock_plc()
    try:
        yield plc
    finally:
        plc.stop()


@pytest.fixture()
def client(mock_plc: MockPlc) -> Iterator[OpcUaClient]:
    c = OpcUaClient(mock_plc.url, security="none")
    c.connect()
    try:
        yield c
    finally:
        c.close()
