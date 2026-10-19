"""Сторожевой таймер задач при импорте (import_sources.watchdog_target, sync_watchdog) — ключ watchdog задачи."""

from __future__ import annotations

import importlib
from typing import Any

import pytest


def module() -> Any:
    # import_sources — скрипт CODESYS (IronPython 2.7); без CODESYS импортируется, mypy его не проверяет
    return importlib.import_module("import_sources")


class FakeWatchdog:
    """ScriptWatchdog задачи CODESYS 3.5.17: у новой задачи выключен, время пустое, чувствительность '1'."""

    def __init__(self) -> None:
        self.enabled = False
        self.time = ""
        self.time_unit = "ms"
        self.sensitivity = "1"


def test_target_parses_config() -> None:
    m = module()
    assert m.watchdog_target({"time_ms": 100, "sensitivity": 2}) == (True, "100", "2")
    assert m.watchdog_target({"time_ms": 100}) == (True, "100", "1")
    assert m.watchdog_target(False) == (False, "", "")


@pytest.mark.parametrize(
    "cfg",
    [True, None, {}, {"time_ms": 0}, {"time_ms": 1.5}, {"time_ms": True}, {"time_ms": 100, "sensitivity": 0}, {"t": 1}],
)
def test_target_rejects_bad_config(cfg: Any) -> None:
    with pytest.raises(ValueError):
        module().watchdog_target(cfg)


def test_sync_enables_then_is_idempotent() -> None:
    m = module()
    wd = FakeWatchdog()
    assert m.sync_watchdog(wd, (True, "100", "1")) == "watchdog=100ms/1"
    assert (wd.enabled, wd.time, wd.time_unit, wd.sensitivity) == (True, "100", "ms", "1")
    assert m.sync_watchdog(wd, (True, "100", "1")) is None
    wd.time_unit = "us"
    assert m.sync_watchdog(wd, (True, "100", "1")) == "watchdog=100ms/1"
    assert wd.time_unit == "ms"


def test_sync_disables() -> None:
    m = module()
    wd = FakeWatchdog()
    assert m.sync_watchdog(wd, (False, "", "")) is None
    wd.enabled = True
    assert m.sync_watchdog(wd, (False, "", "")) == "watchdog=off"
    assert wd.enabled is False
