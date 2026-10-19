"""Примитивы сценариев ПМИ без OPC UA (DESIGN, раздел 14.3): подстановки с арифметикой и сравнения значений
сценария, проверки «всё время» (условия с охраной, размах, скорость), записи журнала со значением, отсутствие
записей, порядок журнала, задержка от записи после метки, смена ускорения, И0 с остановкой насосов, разбор новых
ключей файла.
"""

from __future__ import annotations

from collections.abc import Callable, Mapping, Sequence
from typing import Any

import pytest

from fake_plc import FakeClock, FakeJournalPlc, FakePlc
from kns_scenarios.alarms import ALARM_VIEW, AlarmView, load_alarm_list
from kns_scenarios.client import evaluate, placeholder_names, substitute
from kns_scenarios.context import (
    CMD_SEQ,
    STATION_CMD,
    STATION_STS,
    TIME_NOW,
    TIME_SCALE,
    ExpressionError,
    ScenarioContext,
    ScenarioTimeout,
)
from kns_scenarios.enums import ENUMS
from kns_scenarios.journal import FEED, EventFeed
from kns_scenarios.scenario import (
    DEFAULT_RUN_HOURS_S,
    FEED_POLL_MIN_S,
    PASS,
    Runner,
    ScenarioError,
    ScenarioResult,
    parse_scenario,
)
from kns_scenarios.values import LiteralError, PlcValue, compare

K = 20.0
POLL_S = 0.25
PUMPS = (1, 2, 3)
STATE = ENUMS["E_AlarmState"]
STATION_EVENT = 2  # E_EventKind.Station
EV_LEAD = 101005
EV_START = 101015
EV_FAULT_INJ = 101021
P101_FBL = 111
LT101_H = 1011
KNS1_SIM = 100013


class ScriptedPlc(FakeJournalPlc):
    """Журнал и значения как функции времени исполнителя (``FakeClock``): процесс идёт, пока сценарий ждёт."""

    def __init__(self, clk: FakeClock, values: Mapping[str, PlcValue] | None = None) -> None:
        super().__init__(values)
        self.clk = clk
        self.script: dict[str, Callable[[float], PlcValue]] = {}
        self.feed_reads = 0

    def read(self, paths: Sequence[str]) -> list[PlcValue]:
        for path in paths:
            if path in self.script:
                self.values[path] = self.script[path](self.clk.now)
        if any(p.startswith(FEED + ".") for p in paths):
            self.feed_reads += 1
        return super().read(paths)


def set_alarms(plc: FakePlc, states: Mapping[int, str]) -> None:
    """Строки ``stAlarmView``: номер тревоги → состояние."""
    plc.values[f"{ALARM_VIEW}.uiCount"] = len(states)
    plc.values[f"{ALARM_VIEW}.uiActiveTotal"] = len(states)
    for row, (alarm_id, state) in enumerate(states.items(), 1):
        plc.values[f"{ALARM_VIEW}.astRow[{row}].udiId"] = alarm_id
        plc.values[f"{ALARM_VIEW}.astRow[{row}].eState"] = STATE[state]


def make_runner(plc: FakeJournalPlc, clk: FakeClock | None = None, k: float = K) -> tuple[Runner, ScenarioContext]:
    clk = clk or FakeClock()
    ctx = ScenarioContext(plc, time_scale=k, poll_s=POLL_S, margin_s=1.0, enums=ENUMS, clock=clk.clock, sleep=clk.sleep)
    plc.values.setdefault(TIME_NOW, 100.0)
    set_alarms(plc, {})
    feed = EventFeed(plc)
    feed.start_at_end()
    return Runner(ctx, "opcua", alarms=AlarmView(plc, load_alarm_list(), ENUMS), feed=feed), ctx


def run_steps(runner: Runner, steps: list[dict[str, Any]], k: float = K) -> ScenarioResult:
    sc = parse_scenario({"id": "PMI-12", "title": "t", "time_scale": k, "step": steps})
    result = ScenarioResult(sc.id, sc.title, "opcua", k)
    runner.run_steps(sc.steps, sc.timeout_s, result)
    return result


def checks(result: ScenarioResult, text: str) -> list[bool | None]:
    return [c.ok for c in result.checks if text in c.text]


# --- подстановки и сравнения ---------------------------------------------------------------------


def test_substitute_arithmetic_comparisons_and_marks() -> None:
    assert substitute("GVL_Devices.fbP10{lead}.stSts.eState", {"lead": 2}) == "GVL_Devices.fbP102.stSts.eState"
    assert substitute("udiStarts = {s+1}", {"s": 5}) == "udiStarts = 6"
    assert substitute("{0.5*(a+b)}", {"a": 10, "b": 5}) == "7.5"
    assert substitute("{t2-t1}", {"t1": 10.0, "t2": 15.25}) == "5.25"
    assert substitute("{q <= 213}", {"q": 200.0}) == "TRUE"
    assert substitute("{ov * (q <= 213)}", {"ov": 3, "q": 250.0}) == "0"
    assert substitute("{not x and y}", {"x": False, "y": True}) == "TRUE"
    assert evaluate("-a", {"a": 2}) == -2
    assert placeholder_names("e1-h1+0.2*(x)") == {"e1", "h1", "x"}
    with pytest.raises(KeyError):
        substitute("{s+1}", {})
    for bad in ("{f(x)}", "{a.b}", "{'x'}", "{a[0]}", "{1 +}"):
        with pytest.raises(ValueError):
            substitute(bad, {"a": 1, "x": 1, "f": 1})
    with pytest.raises(ValueError):
        substitute("{s+1}", {"s": "текст"})


def test_no_common_bits_operator() -> None:
    assert compare(0x0001, "!&", 0x0400) and not compare(0x0401, "!&", 0x0400)
    assert compare(0x0401, "&", 0x0400)
    with pytest.raises(LiteralError):
        compare(1.0, "!&", 1)


def test_local_comparison_does_not_read_plc() -> None:
    plc = FakePlc()  # чтение любого пути — KeyError
    ctx = ScenarioContext(plc, enums=ENUMS, captures={"a": 37, "b": 32, "x": True})
    assert ctx.check("{a-b} >= 4") == (True, 5)
    assert ctx.check("{a} <= {b+4}") == (False, 37)
    assert ctx.check("{x} = TRUE") == (True, True)
    with pytest.raises(ScenarioTimeout):
        ctx.wait("{a-b} < 1", 10.0)  # постоянное условие: ждать нечего
    with pytest.raises(ExpressionError):
        ctx.condition("{a}")


def test_mark_is_also_a_substitution_value() -> None:
    plc = FakePlc({TIME_NOW: 12.5})
    ctx = ScenarioContext(plc, enums=ENUMS)
    assert ctx.mark("t_loss") == 12.5
    assert ctx.captures["t_loss"] == 12.5 and ctx.path("{t_loss+30}") == "42.5"


def test_hold_with_tick_samples_each_poll_period() -> None:
    clk = FakeClock()
    ctx = ScenarioContext(FakePlc(), time_scale=K, poll_s=POLL_S, clock=clk.clock, sleep=clk.sleep)
    ticks: list[float] = []
    ctx.hold(10.0, lambda: ticks.append(clk.now))  # 0,5 с реального времени — два периода опроса
    assert len(ticks) == 2 and clk.now == pytest.approx(0.5)
    slept: list[float] = []
    ctx.sleep = slept.append
    ctx.hold(30.0)
    assert slept == [1.5]


# --- проверки «всё время» ------------------------------------------------------------------------


def test_during_reports_violation_and_respects_guard() -> None:
    clk = FakeClock()
    plc = ScriptedPlc(clk, {"GVL_T.xRun": True, "GVL_T.xGuard": True})
    runner, _ = make_runner(plc, clk)
    plc.script["GVL_T.xRun"] = lambda t: t < 0.3  # насос «остановился» через 0,3 с реального времени
    plc.script["GVL_T.xGuard"] = lambda t: t < 0.2
    result = run_steps(
        runner,
        [
            {"hold_s": 20, "during": ["GVL_T.xRun = TRUE"]},
            {"hold_s": 20, "during_if": [{"when": ["GVL_T.xGuard = TRUE"], "then": ["GVL_T.xRun = TRUE"]}]},
            {
                "hold_s": 20,
                "during": ["GVL_T.xGuard = FALSE"],
                "during_if": [
                    {"when": ["GVL_T.xGuard = FALSE"], "then": ["GVL_T.xRun = FALSE"]},
                    {"when": ["GVL_T.xRun = TRUE"], "then": ["GVL_T.xGuard = TRUE"]},
                ],
            },
        ],
    )
    during = [c for c in result.checks if c.text.startswith("всё время")]
    # шаг 1 — нарушение; шаг 2 — все отсчёты вне охраны; шаг 3 — без охраны и две группы с разной охраной
    assert [c.ok for c in during] == [False, None, True, True, None]
    assert during[0].actual is False and "нарушений" in during[0].note
    assert during[1].text.startswith("всё время: при GVL_T.xGuard = TRUE: ")


def test_during_span_rate_and_span_capture() -> None:
    clk = FakeClock()
    plc = ScriptedPlc(clk)
    runner, ctx = make_runner(plc, clk)
    plc.script[TIME_NOW] = lambda t: 100.0 + t * K
    plc.script["GVL_T.rRef"] = lambda t: 60.0 + 5.0 * t * K  # рампа 5 %/с контура
    result = run_steps(
        runner,
        [
            {
                "hold_s": 8,
                "during_rate": {"GVL_T.rRef": 5.5},
                "during_span": {"GVL_T.rRef": {"max": 50, "min": 10, "capture": "ref"}},
            },
            {"hold_s": 8, "during_rate": {"GVL_T.rRef": 4.0}, "during_span": {"GVL_T.rRef": 1.0}},
        ],
    )
    assert checks(result, "скорость GVL_T.rRef ≤ 5.5") == [True]
    assert checks(result, "скорость GVL_T.rRef ≤ 4") == [False]
    assert checks(result, "размах GVL_T.rRef ≤ 50 и ≥ 10") == [True]
    assert checks(result, "размах GVL_T.rRef ≤ 1") == [False]
    assert ctx.captures["ref_min"] == pytest.approx(60.0) and float(ctx.captures["ref_max"]) > 60.0
    assert any("скорость" in key for key in result.measured)


def test_during_checks_reported_when_wait_times_out() -> None:
    clk = FakeClock()
    plc = ScriptedPlc(clk, {"GVL_T.xRun": False, "GVL_T.xDone": False, "GVL_Sim.stSimCfg.rTimeScale": K})
    runner, _ = make_runner(plc, clk)
    sc = parse_scenario(
        {
            "id": "PMI-12",
            "title": "t",
            "time_scale": K,
            "setup": {"skip_initial_state": True},
            "step": [{"wait": "GVL_T.xDone = TRUE", "timeout_s": 5, "during": ["GVL_T.xRun = TRUE"]}],
            "teardown": {"clear_faults": False},
        }
    )
    runner.initial_state = lambda setup: None  # type: ignore[method-assign]
    result = runner.run(sc)
    assert result.error is not None and "не выполнено" in result.error
    assert checks(result, "всё время: GVL_T.xRun = TRUE") == [False]


def test_feed_polled_during_long_hold() -> None:
    clk = FakeClock()
    plc = ScriptedPlc(clk)
    runner, _ = make_runner(plc, clk)
    before = plc.feed_reads
    run_steps(runner, [{"hold_s": 4 * FEED_POLL_MIN_S * K}])  # 4 с реального времени
    assert plc.feed_reads - before >= 4


# --- журнал --------------------------------------------------------------------------------------


def test_expect_event_value_since_mark_and_after_plc_restart() -> None:
    plc = FakeJournalPlc({"GVL_T.xCmd": False})
    runner, _ = make_runner(plc)
    plc.add(EV_LEAD, 0, 1.0, kind=STATION_EVENT, value=1.0)  # прежний ведущий — до метки
    assert runner.feed is not None
    runner.feed.poll()

    def react(values: Mapping[str, PlcValue]) -> None:
        if values.get("GVL_T.xCmd") is True:
            plc.add(EV_LEAD, 0, 2.0, kind=STATION_EVENT, value=2.0)

    plc.on_write = react
    result = run_steps(
        runner,
        [
            {"write": {"GVL_T.xCmd": True}, "mark": "c2"},
            {"timeout_s": 5, "expect_event": [{"event": "KNS1.E5", "value": 2, "since": "c2"}]},
            {"timeout_s": 5, "expect_event": {"event": "KNS1.E5", "value": 1, "since": "c2"}},
            {"timeout_s": 5, "expect_event": {"event": "KNS1.E5", "value": 1}},
        ],
    )
    assert checks(result, f"запись {EV_LEAD}") == [True, False, True]
    failed = next(c for c in result.checks if c.ok is False)
    assert failed.actual == [2.0] and failed.note == "другое значение"
    plc.restart()  # сброс ПЛК: номера журнала снова с 1, граница метки — по записям курсора
    plc.add(EV_START, 0, 0.5, kind=STATION_EVENT)
    result = run_steps(runner, [{"timeout_s": 5, "expect_event": {"event": "KNS1.E15", "since": "c2"}}])
    assert checks(result, f"запись {EV_START}") == [True]


def test_expect_absent_any_alarm_except_single_alarm_and_event() -> None:
    plc = FakeJournalPlc({"GVL_T.xCmd": False})
    runner, _ = make_runner(plc)

    def react(values: Mapping[str, PlcValue]) -> None:
        if values.get("GVL_T.xCmd") is True:
            plc.add(KNS1_SIM, mono_s=1.0)
            plc.add(LT101_H, mono_s=1.0)

    plc.on_write = react
    result = run_steps(
        runner,
        [
            {"write": {"GVL_T.xCmd": True}, "mark": "t0"},
            {
                "expect_absent": [
                    {"any_alarm": True, "except": ["KNS1.SIM"], "since": "t0"},
                    {"any_alarm": True, "except": ["KNS1.SIM", "LT101.H"]},
                    {"alarm": "KNS1.ATS", "since": "t0"},
                    {"alarm": "LT101.H", "state": "RtnUnack"},
                    {"event": "KNS1.E6"},
                ]
            },
        ],
    )
    absent = [c for c in result.checks if c.text.startswith("нет")]
    assert [c.ok for c in absent] == [False, True, True, True, True]
    assert absent[0].actual == ["LT101.H"]


def test_expect_log_order_detects_time_going_back() -> None:
    plc = FakeJournalPlc()
    runner, _ = make_runner(plc)
    plc.add(LT101_H, mono_s=1.0, utc_ms=1000)
    plc.add(LT101_H, mono_s=2.0, utc_ms=2000)
    plc.restart()
    plc.add(EV_START, 0, 0.1, kind=STATION_EVENT, utc_ms=3000)  # новый журнал после сброса — не нарушение
    plc.add(LT101_H, mono_s=0.5, utc_ms=3500)
    result = run_steps(runner, [{"expect_log_order": True}, {"expect_log_order": True}])
    assert checks(result, "не убывает") == [True, True]
    plc.add(LT101_H, mono_s=0.2, utc_ms=3600)  # время процесса назад
    result = run_steps(runner, [{"expect_log_order": True}])
    assert checks(result, "не убывает") == [False]


def test_expect_alarm_and_wait_alarm_list() -> None:
    plc = FakeJournalPlc()
    runner, _ = make_runner(plc)
    set_alarms(plc, {100004: "SuppressedByDesign", 100003: "ActiveUnack"})
    result = run_steps(
        runner,
        [
            {
                "timeout_s": 5,
                "wait_alarm": [{"code": "KNS1.LACK"}, {"code": "KNS1.NORES", "state": "SuppressedByDesign"}],
                "expect_alarm": [{"code": "KNS1.NORES", "state": "SuppressedByDesign"}, {"code": "KNS1.ATS"}],
            }
        ],
    )
    assert [c.ok for c in result.checks] == [True, True, True, False]


def test_expect_delay_since_takes_source_after_mark() -> None:
    plc = FakeJournalPlc({"GVL_T.xCmd": False})
    runner, _ = make_runner(plc)
    plc.add(EV_FAULT_INJ, 0, 10.0, kind=STATION_EVENT)  # прежняя инъекция
    assert runner.feed is not None
    runner.feed.poll()

    def react(values: Mapping[str, PlcValue]) -> None:
        if values.get("GVL_T.xCmd") is True:
            plc.add(EV_FAULT_INJ, 0, 50.0, kind=STATION_EVENT)
            plc.add(P101_FBL, mono_s=50.8)

    plc.on_write = react
    result = run_steps(
        runner,
        [
            {"write": {"GVL_T.xCmd": True}, "mark": "t1"},
            {
                "timeout_s": 5,
                "expect_delay": [
                    {"since": "t1", "from_event": "KNS1.E21", "alarm": "P101.FBL", "min_s": 0.1, "max_s": 1.3},
                    {"from_event": "KNS1.E21", "alarm": "P101.FBL", "max_s": 1.3},
                ],
            },
        ],
    )
    delays = sorted(result.measured.values())
    assert delays == [pytest.approx(0.8), pytest.approx(40.8)]
    assert checks(result, "задержка") == [True, False]


def test_expect_delay_target_logged_earlier_in_same_cycle() -> None:
    """KNS1.ATS и KNS1.UL1 в одном цикле: ATS записана раньше (номер меньше, метка lrMono_s на доли мс меньше)."""
    plc = FakeJournalPlc()
    runner, _ = make_runner(plc)
    ats = load_alarm_list()["KNS1.ATS"].id
    ul1 = load_alarm_list()["KNS1.UL1"].id
    plc.add(ats, mono_s=100.0)
    plc.add(ul1, mono_s=100.00002)
    plc.add(ats, STATE["ActiveAck"], mono_s=99.0)  # другое состояние не мешает
    result = run_steps(
        runner,
        [
            {
                "timeout_s": 5,
                "expect_delay": {"from_alarm": "KNS1.UL1", "alarm": "KNS1.ATS", "min_s": 0.0, "max_s": 0.8},
            }
        ],
    )
    assert checks(result, "задержка") == [True]
    assert list(result.measured.values()) == [pytest.approx(0.0, abs=1e-3)]


def test_capture_after_wait_in_same_step() -> None:
    """``capture`` берёт значение, когда условие шага выполнено (после ``hold_s``/``wait``), а не в начале шага."""
    plc = FakeJournalPlc({"GVL_T.rSpeed": 60.0, "GVL_T.xReady": False})
    clk = FakeClock()
    runner, _ = make_runner(plc, clk)
    reads = {"n": 0}
    base_read = plc.read

    def read(paths: Sequence[str]) -> list[PlcValue]:
        if "GVL_T.xReady" in paths:
            reads["n"] += 1
            if reads["n"] >= 3:  # ПЛК «досчитал»: готовность и новая частота
                plc.values.update({"GVL_T.xReady": True, "GVL_T.rSpeed": 88.0})
        return base_read(paths)

    plc.read = read  # type: ignore[method-assign]
    result = run_steps(
        runner,
        [{"wait": "GVL_T.xReady = TRUE", "timeout_s": 60, "capture": {"sp": "GVL_T.rSpeed"}, "expect": ["{sp} = 88"]}],
    )
    assert runner.ctx.captures["sp"] == 88.0
    assert checks(result, "{sp} = 88") == [True]


# --- шаги и И0 -----------------------------------------------------------------------------------


def test_initial_state_waits_for_start_windows() -> None:
    """Окно пусков Н1 у предела: И0 при k = 50 и притоке 0 ждёт, пока пуски не выйдут из окна, затем k сценария."""
    starts = "GVL_Devices.fbP101.stSts.uiStartsLastHour"
    plc = FakeJournalPlc(
        {f"GVL_Persist.stP10{n}Cfg.uiMaxStartsPerHour": 10 for n in PUMPS}
        | {f"GVL_Devices.fbP10{n}.stSts.uiStartsLastHour": 0 for n in PUMPS}
        | {starts: 10}
    )
    clk = FakeClock()
    runner, ctx = make_runner(plc, clk)
    base_read = plc.read

    def read(paths: Sequence[str]) -> list[PlcValue]:
        if starts in paths and plc.values.get(TIME_SCALE) == 50.0:
            plc.values[starts] = max(int(plc.values[starts]) - 1, 0)  # старые пуски выходят из окна
        return base_read(paths)

    plc.read = read  # type: ignore[method-assign]
    runner._wait_start_windows()
    assert plc.values[starts] == 7  # 10 − START_RESERVE
    assert plc.values["GVL_Sim.stSimCmd.rInflowOverride_m3h"] == 0.0
    assert plc.values[TIME_SCALE] == K and ctx.time_scale == K
    plc.values[starts] = 3
    plc.writes.clear()
    runner._wait_start_windows()  # окно свободно — ничего не пишет
    assert plc.writes == []


def test_time_scale_init_manual_and_not_checked_steps() -> None:
    plc = FakeJournalPlc({"GVL_T.xOk": True})
    runner, ctx = make_runner(plc)
    inits: list[Mapping[str, Any]] = []
    runner.initial_state = lambda setup: inits.append(setup)  # type: ignore[method-assign]
    result = run_steps(
        runner,
        [
            {"time_scale": 1, "init": {"inflow_m3h": 60.0}, "expect": ["GVL_T.xOk = TRUE"]},
            {"manual": "экран «Обзор»", "not_checked": "LT101.H за 2 мин не достигается"},
        ],
    )
    assert plc.values[TIME_SCALE] == 1.0 and ctx.time_scale == 1.0
    assert inits == [{"inflow_m3h": 60.0}]
    notes = [c.note for c in result.checks if c.ok is None]
    assert any("вручную" in n for n in notes) and any("не проверяется" in n for n in notes)
    assert result.verdict == PASS


def test_initial_state_stops_pumps_before_run_hours() -> None:
    plc = FakeJournalPlc(
        {CMD_SEQ: 0, f"{STATION_STS}.uiPumpsRunning": 1, f"{STATION_STS}.eControlAct": ENUMS["E_ControlAct"]["Float"]}
        | {f"GVL_Persist.stP10{n}Cfg.uiMaxStartsPerHour": 10 for n in PUMPS}
        | {f"GVL_Devices.fbP10{n}.stSts.uiStartsLastHour": 0 for n in PUMPS}
    )

    def plc_cycle(values: Mapping[str, PlcValue]) -> None:
        for path, value in values.items():
            if value is True and path.split(".")[-1].startswith("x") and "Override" not in path:
                plc.values[path] = False  # импульс сброшен «ПЛК»
                if path.startswith(STATION_CMD + "."):
                    plc.values[CMD_SEQ] = int(plc.values[CMD_SEQ]) + 1
                if path.endswith(".xStop"):
                    plc.values[f"{STATION_STS}.uiPumpsRunning"] = 0
                if path.endswith("stP103Cmd.stCommon.xSetAuto"):
                    plc.values[f"{STATION_STS}.eControlAct"] = ENUMS["E_ControlAct"]["Stepped"]

    plc.on_write = plc_cycle
    ctx = ScenarioContext(plc, poll_s=0.01, margin_s=0.5, enums=ENUMS)
    Runner(ctx, "opcua").initial_state({"run_hours_s": [1, 2, 3], "method": "Stepped", "level_m": 1.6})
    order = [next(iter(w)) for w in plc.writes]
    first_hours = order.index("GVL_Persist.stP101Retain.udiOpTime_s")
    assert order.index("GVL_Hmi.stP101Cmd.xStop") < first_hours
    assert order.index(f"{STATION_CMD}.xSetAuto") < first_hours
    # LIC101 в Auto (06 §5.2, п. 7): иначе ПИД не готов и «ПИД» действует как ступенчатое (04 §7.4)
    assert order.index("GVL_Station.stLIC101Cmd.stCommon.xSetAuto") < first_hours
    assert order.index("GVL_Hmi.stV1Cmd.stCommon.xSetAuto") < first_hours
    assert order.count("GVL_Sim.stSimCmd.xResetPlant") == 2
    assert order.index("GVL_Sim.stSimCmd.xSetLevel") > first_hours
    assert order[-1] == f"{STATION_CMD}.xAckAll"
    plc.writes.clear()
    plc.values[f"{STATION_STS}.uiPumpsRunning"] = 1
    Runner(ctx, "opcua").initial_state({})  # наработка И0 по умолчанию: ведущий Н1
    hours = {k: v for w in plc.writes for k, v in w.items() if k.endswith("udiOpTime_s")}
    assert hours == {
        f"GVL_Persist.stP10{n}Retain.udiOpTime_s": h for n, h in zip(PUMPS, DEFAULT_RUN_HOURS_S, strict=True)
    }


def test_runner_journal_from_start_and_teardown_write() -> None:
    plc = FakeJournalPlc()
    plc.add(EV_START, 0, 0.0, kind=STATION_EVENT)  # старт приложения — до сценария
    runner, _ = make_runner(plc)
    sc = parse_scenario(
        {
            "id": "PMI-01",
            "title": "t",
            "time_scale": 1,
            "mode": "auto+manual",
            "manual": ["экран"],
            "setup": {"skip_initial_state": True, "journal_from_start": True},
            "step": [{"timeout_s": 5, "expect_event": {"event": "KNS1.E15"}}],
            "teardown": {"clear_faults": False, "write": {"GVL_Sim.stSimCmd.xDoorOpen": False}},
        }
    )
    result = runner.run(sc)
    assert result.error is None and result.verdict == PASS and result.mode == "auto+manual"
    assert plc.writes[-1] == {"GVL_Sim.stSimCmd.xDoorOpen": False}


def test_parse_scenario_new_keys_validated() -> None:
    base: dict[str, Any] = {"id": "PMI-98", "title": "t", "time_scale": 20}
    bad_cases: list[dict[str, Any]] = [
        {"mode": "half"},
        {"step": [{"init": {"levle_m": 1.0}}]},
        {"step": [{"time_scale": 60}]},
        {"step": [{"during_if": [{"when": ["GVL_T.x = TRUE"]}]}]},
        {"step": [{"during_if": ["GVL_T.x = TRUE"]}]},
        {"step": [{"during_span": 5}]},
        {"step": [{"expect_event": "KNS1.E5"}]},
        {"teardown": {"writes": {}}},
    ]
    for extra in bad_cases:
        with pytest.raises(ScenarioError):
            parse_scenario({**base, **extra})
    sc = parse_scenario(
        {
            **base,
            "mode": "auto",
            "setup": {"journal_from_start": True},
            "teardown": {"write": {"GVL_Sim.stSimCmd.xDoorOpen": False}},
            "step": [{"expect": "GVL_T.x = TRUE", "during": ["GVL_T.y = TRUE"], "during_rate": {"GVL_T.r": 5}}],
        }
    )
    assert sc.mode == "auto" and sc.setup["journal_from_start"] is True
