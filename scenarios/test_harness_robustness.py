"""Устойчивость обвязки сценариев без OPC UA: подменный клиент ПЛК с журналом (DESIGN, раздел 14.3).

Время и единицы (TIME — мс, LTIME — нс, как хранит ПЛК), задержки по журналу от метки сценария (запись журнала
раньше чтения метки, допуск только в сторону запаздывания метки), перезапуск журнала после сброса ПЛК,
пропуск записей и переполнение списка тревог — как ошибки сценария, а не ложный успех или зависание.
"""

from __future__ import annotations

from collections.abc import Callable, Mapping, Sequence
from typing import Any

import pytest

from kns_scenarios.alarms import ALARM_VIEW, AlarmView, load_alarm_list
from kns_scenarios.client import NotSupportedError, ResetKind
from kns_scenarios.context import TIME_NOW, ScenarioContext
from kns_scenarios.enums import ENUMS
from kns_scenarios.journal import FEED, FEED_ROWS, RECORD_FIELDS, EventFeed, EventRecord, JournalGap
from kns_scenarios.scenario import FAIL, Runner, ScenarioResult, parse_scenario
from kns_scenarios.values import PlcValue, parse_literal

ACTIVE_UNACK = ENUMS["E_AlarmState"]["ActiveUnack"]
P101_EXT = 114  # dev_no 11 · 10 + слот 4 (05_alarm_list.csv)
FAULT = "GVL_Sim.stFaultInj.axVfdFault[1]"
K = 20.0
POLL_S = 0.25


class FakePlc:
    """Подменный ``PlcClient``: словарь путей; чтение неизвестного пути — KeyError, как узел без символа."""

    def __init__(self, values: Mapping[str, PlcValue] | None = None) -> None:
        self.values: dict[str, PlcValue] = dict(values or {})
        self.writes: list[dict[str, PlcValue]] = []
        self.on_write: Callable[[Mapping[str, PlcValue]], None] | None = None

    def read(self, paths: Sequence[str]) -> list[PlcValue]:
        return [self.values[p] for p in paths]

    def write(self, values: Mapping[str, PlcValue]) -> None:
        self.writes.append(dict(values))
        self.values.update(values)
        if self.on_write is not None:
            self.on_write(values)

    def reset(self, kind: ResetKind) -> None:
        raise NotSupportedError(kind)

    def close(self) -> None:
        pass


class FakeJournalPlc(FakePlc):
    """Журнал и курсор ``stEventFeed`` как ``FB_EventLog.FillFeed``: строки с MAX(udiFromSeq, первая)."""

    def __init__(self, values: Mapping[str, PlcValue] | None = None) -> None:
        super().__init__(values)
        self.journal: list[EventRecord] = []
        self.values.setdefault(f"{FEED}.udiFromSeq", 0)

    def add(self, alarm_id: int, new_state: int = ACTIVE_UNACK, mono_s: float = 0.0) -> EventRecord:
        seq = self.journal[-1].seq + 1 if self.journal else 1
        rec = EventRecord(seq, 1, 2, alarm_id, 0, new_state, 1, 0.0, 0, mono_s)
        self.journal.append(rec)
        return rec

    def restart(self) -> None:
        """Тёплый сброс ПЛК: журнал в ОЗУ пуст, номера снова с 1."""
        self.journal = []

    def fill_feed(self) -> None:
        last = self.journal[-1].seq if self.journal else 0
        first = self.journal[0].seq if self.journal else last + 1
        start = max(int(self.values[f"{FEED}.udiFromSeq"]), first)
        rows = [r for r in self.journal if r.seq >= start][:FEED_ROWS]
        self.values.update({f"{FEED}.udiSeqFirst": first, f"{FEED}.udiSeqLast": last, f"{FEED}.uiCount": len(rows)})
        for row in range(1, FEED_ROWS + 1):
            rec = rows[row - 1] if row <= len(rows) else EventRecord(0, 0, 0, 0, 0, 0, 0, 0.0, 0, 0.0)
            raw = (rec.seq, rec.kind, rec.priority, rec.id, rec.old_state, rec.new_state, rec.reason, rec.value,
                   rec.utc_ms, rec.mono_s)  # fmt: skip
            for name, value in zip(RECORD_FIELDS, raw, strict=True):
                self.values[f"{FEED}.astRow[{row}].{name}"] = value

    def read(self, paths: Sequence[str]) -> list[PlcValue]:
        if any(p.startswith(FEED + ".") for p in paths):
            self.fill_feed()
        return super().read(paths)


class FakeClock:
    """Часы исполнителя: ``sleep`` двигает время, ожидания с таймаутом завершаются без реальных пауз."""

    def __init__(self) -> None:
        self.now = 0.0

    def clock(self) -> float:
        return self.now

    def sleep(self, seconds: float) -> None:
        self.now += max(seconds, 0.01)


def runner_on(plc: FakeJournalPlc) -> tuple[Runner, ScenarioContext]:
    clk = FakeClock()
    ctx = ScenarioContext(plc, time_scale=K, poll_s=POLL_S, margin_s=1.0, enums=ENUMS, clock=clk.clock, sleep=clk.sleep)
    feed = EventFeed(plc)
    feed.start_at_end()
    return Runner(ctx, "opcua", alarms=AlarmView(plc, load_alarm_list(), ENUMS), feed=feed), ctx


def delay_steps(max_s: float) -> list[dict[str, Any]]:
    return [
        {"write": {FAULT: True}, "mark": "t_fault"},
        {
            "timeout_s": 5,
            "expect_delay": {"from": "t_fault", "alarm": "P101.EXT", "state": "ActiveUnack", "max_s": max_s},
        },
    ]


def run_delay(
    plc: FakeJournalPlc, max_s: float = 0.2, earlier: Callable[[], object] | None = None
) -> tuple[bool | None, float | None, str]:
    runner, _ctx = runner_on(plc)
    if earlier is not None:  # записи журнала прежних шагов сценария: курсор их уже прочитал
        earlier()
        assert runner.feed is not None
        runner.feed.poll()
    sc = parse_scenario({"id": "PMI-13", "title": "t", "time_scale": K, "step": delay_steps(max_s)})
    result = ScenarioResult(sc.id, sc.title, "opcua", K)
    runner.run_steps(sc.steps, sc.timeout_s, result)
    check = result.checks[-1]
    return check.ok, result.measured.get(check.step), check.note


# --- TIME и LTIME: единицы ПЛК -------------------------------------------------------------------


def test_time_literal_is_milliseconds_ltime_nanoseconds() -> None:
    assert parse_literal("T#10M") == 600_000 and isinstance(parse_literal("T#10M"), int)
    assert parse_literal("TIME#1S500MS") == 1500
    assert parse_literal("LTIME#200MS") == 200_000_000 and parse_literal("LT#1US") == 1000


def test_time_write_and_compare_in_plc_units() -> None:
    plc = FakePlc({"GVL_Persist.stStationCfg.tMaxContRun": 0})
    ctx = ScenarioContext(plc, enums=ENUMS)
    ctx.write({"GVL_Persist.stStationCfg.tMaxContRun": "T#10M"})  # PMI-11: Cfg.tMaxContRun = T#10M
    assert plc.writes[-1] == {"GVL_Persist.stStationCfg.tMaxContRun": 600_000}
    assert ctx.check("GVL_Persist.stStationCfg.tMaxContRun = T#10M") == (True, 600_000)


# --- задержка от метки сценария ------------------------------------------------------------------


def _plc_with_alarm_after_write(mono_s: float, mark_s: float = 100.0) -> FakeJournalPlc:
    plc = FakeJournalPlc({TIME_NOW: mark_s, FAULT: False})

    def react(values: Mapping[str, PlcValue]) -> None:
        if values.get(FAULT) is True:
            plc.add(P101_EXT, mono_s=mono_s)

    plc.on_write = react
    return plc


def test_delay_from_mark_finds_alarm_logged_before_mark_was_read() -> None:
    # авария записана в журнал через 0,04 с после записи, метку прочитали позже — запись «раньше» метки
    ok, delay, note = run_delay(_plc_with_alarm_after_write(mono_s=99.7))
    assert ok is True, note
    assert delay == pytest.approx(-0.3)


def test_delay_from_mark_max_not_widened_by_poll_tolerance() -> None:
    # 3 с после метки при max_s = 0,2: метка не позже действия, значит настоящая задержка не меньше 3 с
    ok, delay, _note = run_delay(_plc_with_alarm_after_write(mono_s=103.0))
    assert delay == pytest.approx(3.0)
    assert ok is False


def test_delay_from_mark_ignores_same_alarm_logged_before_write() -> None:
    plc = _plc_with_alarm_after_write(mono_s=100.5)
    # прежняя запись той же тревоги до записи сценария (в пределах допуска метки) — не она
    ok, delay, note = run_delay(plc, max_s=1.0, earlier=lambda: plc.add(P101_EXT, mono_s=99.9))
    assert ok is True, note
    assert delay == pytest.approx(0.5)


# --- журнал: перезапуск, пропуск -----------------------------------------------------------------


def test_event_feed_follows_journal_restart_after_plc_reset() -> None:
    plc = FakeJournalPlc()
    for n in range(5):
        plc.add(P101_EXT, mono_s=float(n))
    feed = EventFeed(plc)
    assert [r.seq for r in feed.poll()] == [1, 2, 3, 4, 5]
    plc.restart()
    plc.add(101015, new_state=0, mono_s=0.5)  # PlcStart после сброса: номера с 1
    plc.add(101016, new_state=0, mono_s=0.6)
    records: list[EventRecord] = []
    for _ in range(3):  # курсор переставляется на первую запись нового журнала
        records += feed.poll()
    assert [r.id for r in records] == [101015, 101016]
    assert feed.restarts == 1


def test_event_feed_reports_single_lost_record() -> None:
    plc = FakeJournalPlc()
    for n in range(5):
        plc.add(P101_EXT, mono_s=float(n))
    feed = EventFeed(plc)
    assert len(feed.poll()) == 5  # прочитаны № 1…5, следующий — № 6
    plc.add(P101_EXT, mono_s=5.0)
    plc.add(P101_EXT, mono_s=6.0)
    plc.journal = [r for r in plc.journal if r.seq >= 7]  # кольцо затёрло ровно одну непрочитанную запись (№ 6)
    with pytest.raises(JournalGap, match="6"):
        feed.poll()


def test_runner_reports_journal_gap_as_scenario_error() -> None:
    plc = FakeJournalPlc({TIME_NOW: 0.0, "GVL_Sim.stSimCmd.rInflowOverride_m3h": 0.0})
    runner, _ctx = runner_on(plc)
    feed = runner.feed
    assert feed is not None

    def gap() -> list[EventRecord]:
        raise JournalGap("записи 10…20 затёрты между опросами журнала")

    feed.poll = gap  # type: ignore[method-assign]
    sc = parse_scenario(
        {
            "id": "PMI-37",
            "title": "t",
            "time_scale": K,
            "setup": {"skip_initial_state": True},
            "step": [{"note": "опрос журнала"}],
            "teardown": {"clear_faults": False, "inflow_m3h": 50.0},
        }
    )
    runner.initial_state = lambda setup: None  # type: ignore[method-assign]
    runner.ctx.set_time_scale = lambda k: None  # type: ignore[method-assign]
    feed.start_at_end = lambda: 1  # type: ignore[method-assign]
    result = runner.run(sc)
    assert result.verdict == FAIL
    assert result.error is not None and "затёрты" in result.error
    assert plc.writes[-1] == {"GVL_Sim.stSimCmd.rInflowOverride_m3h": 50.0}  # завершение выполнено


# --- список тревог: переполнение -----------------------------------------------------------------


def test_alarm_view_overflow_is_not_reported_as_normal() -> None:
    rows = {f"{ALARM_VIEW}.astRow[{r}].udiId": 1000 + r for r in range(1, 51)}
    rows |= {f"{ALARM_VIEW}.astRow[{r}].eState": ACTIVE_UNACK for r in range(1, 51)}
    plc = FakePlc({f"{ALARM_VIEW}.uiCount": 50, f"{ALARM_VIEW}.uiActiveTotal": 60, **rows})
    view = AlarmView(plc, load_alarm_list(), ENUMS)
    assert view.state("P101.EXT") != "Normal"  # 10 тревог не поместились: состояние неизвестно
    plc.values[f"{ALARM_VIEW}.uiActiveTotal"] = 50
    assert view.state("P101.EXT") == "Normal"
