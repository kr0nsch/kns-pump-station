"""Сценарий ПМИ — декларативный файл TOML и его исполнение (DESIGN, раздел 14.3).

Файл: ``id``, ``title``, ``time_scale``, ``timeout_s`` (таймаут шага по умолчанию, секунды контура),
``backends``, ``mode`` (``auto``, ``auto+manual``, ``manual`` — колонка «Вид» приложения А 06_PMI),
``manual`` (что отмечает инженер), таблица ``[setup]`` (исходное состояние И0 06 §5.2 и отличия проверки), шаги
``[[step]]`` и ``[teardown]``.

Ключи шага выполняются в этом порядке (другой порядок — отдельные шаги):

1. ``time_scale`` — ускорение контура с этого шага (короткие участки при k = 1: импульс 1 с, отсчёт 10 с, первые
   2 с отказа — опрос 0,25 с различает их только без ускорения); ``init`` — И0 06 §5.2 посреди сценария
   (таблица — как ``[setup]``); ``reset`` — сброс ПЛК (только исполнитель ``cds``);
2. действия: ``write``, ``pulse``, ``mark`` (время контура после записи, оно же значение ``{имя}``);
3. ожидания: ``hold_s``, ``wait``, ``wait_alarm`` (таблица или список), затем ``capture`` — значения в момент, когда
   условия шага выполнены (до прогона ПМИ 19.10.2026 ``capture`` шёл до ожиданий и брал значение начала шага);
4. проверки «здесь и сейчас»: ``expect``, ``expect_alarm``; по журналу: ``expect_delay`` (таблица или список),
   ``expect_event``, ``expect_absent``, ``expect_log_order``;
5. ``manual`` (часть проверки, которую отмечает инженер) и ``not_checked`` (не проверяется — с причиной) — в отчёт
   как «не проверялось»;
6. ``repeat`` + ``steps``.

Проверки «всё время» шага действуют на время его ``hold_s``, ``wait`` и ``wait_alarm`` (отсчёт — после действий
шага и затем каждый период опроса): ``during`` — условия; ``during_if`` — список ``{when = [...], then = [...]}``:
условия ``then`` проверяются только в отсчётах, где выполнены все условия ``when`` (требования вида «при ливне —
аварийный режим», «в паузах между ливнями — уровень у задания»); ``during_span`` — размах значения (число — не
больше; таблица ``max``, ``min``, ``capture`` — границы и имя ``<capture>_min``/``_max`` для подстановок и
отчёта); ``during_rate`` — наибольшая скорость изменения, ед./с контура (по ``GVL_Time.lrMainNow_s`` того же
чтения). Курсор журнала во время выдержек и ожиданий читается не реже раза в секунду: длинная выдержка (сутки
PMI-39) не теряет записей кольца.

Неуспех ``expect``, проверок по журналу и «всё время» не прерывает сценарий — отчёт собирает все проверки;
таймаут ``wait`` прерывает (дальше проверять нечего). Любая другая ошибка шага (пропуск записей журнала, неверный
литерал, обрыв связи) тоже прерывает сценарий и попадает в отчёт как его ошибка, завершение выполняется всегда.

Границы поиска в журнале — номер записи курсора (``EventFeed.records``), запомненный до действий шага с ``mark``:
он не зависит от номеров ПЛК и переживает сброс (журнал в ОЗУ начинается заново). ``expect_delay`` от метки
сценария: метка ``lrMainNow_s`` читается после записи, поэтому она не раньше действия (с точностью до цикла
MainTask, в начале которого ``lrMainNow_s`` обновляется) и запаздывает не больше чем на «период опроса · k».
Запись журнала ищется среди записей после границы метки (она может оказаться раньше метки), допуск
«период опроса · k» — только для ``min_s``, для ``max_s`` — один цикл MainTask · k: измеренная задержка не больше
настоящей. Между записями журнала (``from_alarm``/``from_event``, граница — ``since``) допуска нет: его задаёт
сценарий (06 §5.3).
"""

from __future__ import annotations

import datetime as dt
import itertools
import tomllib
from collections.abc import Callable, Mapping, Sequence
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from kns_scenarios.alarms import AlarmView
from kns_scenarios.client import NotSupportedError
from kns_scenarios.context import (
    FAN_CMD,
    FAULT_INJ,
    PID_CMD,
    SIM_CMD,
    STATION_CMD,
    STATION_STS,
    TIME_NOW,
    Condition,
    ScenarioContext,
    ScenarioTimeout,
)
from kns_scenarios.journal import EventFeed, EventRecord, event_id, find
from kns_scenarios.values import PlcValue, compare

STEP_KEYS = frozenset(
    {
        "note",
        "time_scale",
        "init",
        "reset",
        "write",
        "pulse",
        "mark",
        "capture",
        "hold_s",
        "wait",
        "wait_alarm",
        "expect",
        "expect_alarm",
        "expect_delay",
        "expect_event",
        "expect_absent",
        "expect_log_order",
        "during",
        "during_if",
        "during_span",
        "during_rate",
        "manual",
        "not_checked",
        "repeat",
        "steps",
        "timeout_s",
    }
)
TOP_KEYS = frozenset(
    {"id", "title", "time_scale", "timeout_s", "backends", "mode", "manual", "setup", "step", "teardown"}
)
SETUP_KEYS = frozenset({"method", "level_m", "inflow_m3h", "run_hours_s", "skip_initial_state", "journal_from_start"})
TEARDOWN_KEYS = frozenset({"clear_faults", "inflow_m3h", "write"})
BACKENDS = frozenset({"opcua", "cds"})
MODES = ("auto", "auto+manual", "manual")  # 06, приложение А, колонка «Вид»
PUMPS = 3  # GVL_Const.STN_PUMP_COUNT
DEFAULT_INFLOW_M3H = 100.0  # 06 §5.2, п. 3
DEFAULT_RUN_HOURS_S = (360_000, 720_000, 1_080_000)  # 06 §5.2, п. 8: Н1 100 ч, Н2 200 ч, Н3 300 ч — ведущий Н1
MAIN_CYCLE_S = 0.02  # период MainTask (DESIGN, раздел 12): шаг метки lrMainNow_s
SAME_CYCLE_FRACTION = 0.5  # записи журнала ближе полцикла — один цикл MainTask
TIME_SCALE_RANGE = (1.0, 50.0)  # SIM_TIME_SCALE_MAX
STOP_TIMEOUT_S = 120.0  # И0: насосы остановлены (выбег ПЧ 10 с), секунды контура
CONTROL_TIMEOUT_S = 180.0  # И0: действует ступенчатое или ПИД (выход из Float — tLtRecover, из Restart — 13 с)
FEED_POLL_MIN_S = 1.0  # курсор журнала во время выдержек и ожиданий, реальные секунды
VALUE_TOL = 1e-3  # допуск значения события журнала (номер насоса, параметра, число строк)
PASS = "соответствует"
FAIL = "не соответствует"
NOT_CHECKED = "не проверялось"


class ScenarioError(ValueError):
    """Файл сценария не соответствует схеме."""


@dataclass
class Scenario:
    """Разобранный файл сценария."""

    id: str
    title: str
    time_scale: float
    timeout_s: float
    backends: list[str]
    manual: list[str]
    setup: dict[str, Any]
    steps: list[dict[str, Any]]
    teardown: dict[str, Any]
    path: Path | None = None
    mode: str = "auto"


def as_list(value: Any) -> list[Any]:
    """Таблица или список таблиц ключа шага (``wait_alarm``, ``expect_delay``, ``expect_event``…) → список."""
    if value is None:
        return []
    return list(value) if isinstance(value, list) else [value]


def _check_steps(steps: Sequence[Any], where: str) -> None:
    for index, step in enumerate(steps, 1):
        at = f"{where}, шаг {index}"
        if not isinstance(step, dict):
            raise ScenarioError(f"{at}: ожидается таблица")
        unknown = sorted(set(step) - STEP_KEYS)
        if unknown:
            raise ScenarioError(f"{at}: неизвестные ключи {unknown}")
        if "repeat" in step and not isinstance(step.get("steps"), list):
            raise ScenarioError(f"{at}: repeat без вложенных steps")
        if "init" in step and (not isinstance(step["init"], dict) or set(step["init"]) - SETUP_KEYS):
            raise ScenarioError(f"{at}: init — таблица с ключами {sorted(SETUP_KEYS)}")
        if "time_scale" in step and not TIME_SCALE_RANGE[0] <= float(step["time_scale"]) <= TIME_SCALE_RANGE[1]:
            raise ScenarioError(f"{at}: time_scale вне {TIME_SCALE_RANGE}")
        for key in ("during", "expect"):
            if key in step and not all(isinstance(e, str) for e in as_list(step[key])):
                raise ScenarioError(f"{at}: {key} — список выражений")
        for group in as_list(step.get("during_if")):
            if not isinstance(group, dict) or set(group) != {"when", "then"}:
                raise ScenarioError(f"{at}: during_if — таблицы when = [...], then = [...]")
        for key in ("during_span", "during_rate"):
            if key in step and not isinstance(step[key], dict):
                raise ScenarioError(f"{at}: {key} — таблица путь → предел")
        for key in ("wait_alarm", "expect_alarm", "expect_delay", "expect_event", "expect_absent"):
            if key in step and not all(isinstance(e, dict) for e in as_list(step[key])):
                raise ScenarioError(f"{at}: {key} — таблица или список таблиц")
        if "steps" in step:
            _check_steps(step["steps"], at)


def parse_scenario(data: Mapping[str, Any], path: Path | None = None) -> Scenario:
    """Проверка схемы и разбор содержимого TOML."""
    where = str(path) if path else "сценарий"
    unknown = sorted(set(data) - TOP_KEYS)
    if unknown:
        raise ScenarioError(f"{where}: неизвестные ключи {unknown}")
    for key in ("id", "title", "time_scale"):
        if key not in data:
            raise ScenarioError(f"{where}: нет ключа {key}")
    backends = list(data.get("backends", sorted(BACKENDS)))
    if not backends or set(backends) - BACKENDS:
        raise ScenarioError(f"{where}: backends — из {sorted(BACKENDS)}")
    mode = str(data.get("mode", "auto"))
    if mode not in MODES:
        raise ScenarioError(f"{where}: mode — из {list(MODES)}")
    setup = dict(data.get("setup", {}))
    teardown = dict(data.get("teardown", {}))
    if set(setup) - SETUP_KEYS:
        raise ScenarioError(f"{where}: [setup] — неизвестные ключи {sorted(set(setup) - SETUP_KEYS)}")
    if set(teardown) - TEARDOWN_KEYS:
        raise ScenarioError(f"{where}: [teardown] — неизвестные ключи {sorted(set(teardown) - TEARDOWN_KEYS)}")
    steps = list(data.get("step", []))
    _check_steps(steps, where)
    return Scenario(
        id=str(data["id"]),
        title=str(data["title"]),
        time_scale=float(data["time_scale"]),
        timeout_s=float(data.get("timeout_s", 60.0)),
        backends=backends,
        manual=list(data.get("manual", [])),
        setup=setup,
        steps=steps,
        teardown=teardown,
        path=path,
        mode=mode,
    )


def load_scenario(path: Path) -> Scenario:
    with path.open("rb") as handle:
        return parse_scenario(tomllib.load(handle), path)


@dataclass
class Check:
    """Итог одной проверки шага."""

    step: str
    text: str
    ok: bool | None  # None — не проверялось
    actual: Any = None
    note: str = ""


@dataclass
class ScenarioResult:
    """Итог сценария для отчёта (заготовка протокола 07)."""

    id: str
    title: str
    backend: str
    time_scale: float
    checks: list[Check] = field(default_factory=list)
    measured: dict[str, float] = field(default_factory=dict)
    marks: dict[str, float] = field(default_factory=dict)
    manual: list[str] = field(default_factory=list)
    error: str | None = None
    mode: str = "auto"
    started: str = ""  # начало прогона, местное время ISO
    real_s: float | None = None  # длительность прогона (с И0 и завершением), реальные секунды
    process_s: float | None = None  # время контура за прогон (GVL_Time.lrMainNow_s; None — был сброс ПЛК)

    @property
    def verdict(self) -> str:
        if self.error is not None or any(c.ok is False for c in self.checks):
            return FAIL
        if not self.checks or all(c.ok is None for c in self.checks):
            return NOT_CHECKED
        return PASS


@dataclass
class _Span:
    """Размах значения за шаг: границы и имя подстановок."""

    max_span: float | None
    min_span: float | None
    capture: str | None
    low: float | None = None
    high: float | None = None


@dataclass
class _Group:
    """Условия «всё время» с охраной: проверяются только в отсчётах, где выполнены все условия ``when``."""

    when: list[Condition]
    then: list[Condition]
    outside: int = 0  # отсчётов вне охраны


class Monitor:
    """Проверки «всё время» одного шага: условия (с охраной), размах, скорость изменения."""

    def __init__(self, ctx: ScenarioContext, step: Mapping[str, Any]) -> None:
        self.ctx = ctx
        self.groups = [_Group([], [ctx.condition(str(e)) for e in as_list(step.get("during"))])]
        for spec in as_list(step.get("during_if")):
            when = [ctx.condition(str(e)) for e in as_list(spec.get("when"))]
            self.groups.append(_Group(when, [ctx.condition(str(e)) for e in as_list(spec.get("then"))]))
        self.spans: dict[str, _Span] = {}
        for raw_path, spec in dict(step.get("during_span", {})).items():
            if isinstance(spec, dict):
                low, high = spec.get("min"), spec.get("max")
                self.spans[ctx.path(raw_path)] = _Span(
                    float(high) if high is not None else None,
                    float(low) if low is not None else None,
                    str(spec["capture"]) if "capture" in spec else None,
                )
            else:
                self.spans[ctx.path(raw_path)] = _Span(float(spec), None, None)
        self.rates = {ctx.path(p): float(v) for p, v in dict(step.get("during_rate", {})).items()}
        self.samples = 0
        self.violations: dict[tuple[int, str], tuple[int, PlcValue]] = {}  # (группа, условие) → (нарушений, первое)
        self.rate_max: dict[str, float] = dict.fromkeys(self.rates, 0.0)
        self.last: dict[str, tuple[float, float]] = {}
        paths = [c.path for g in self.groups for c in g.when + g.then if c.local is None]
        paths += list(self.spans) + list(self.rates)
        if self.rates:
            paths.append(TIME_NOW)
        self.paths = list(dict.fromkeys(paths))

    def _value(self, cond: Condition, values: Mapping[str, PlcValue]) -> PlcValue:
        return cond.local if cond.local is not None else values[cond.path]

    def sample(self) -> None:
        values = dict(zip(self.paths, self.ctx.client.read(self.paths), strict=True)) if self.paths else {}
        self.samples += 1
        for index, group in enumerate(self.groups):
            if not all(compare(self._value(w, values), w.op, w.expected) for w in group.when):
                group.outside += 1
                continue
            for cond in group.then:
                actual = self._value(cond, values)
                if not compare(actual, cond.op, cond.expected):
                    count, first = self.violations.get((index, cond.text), (0, actual))
                    self.violations[(index, cond.text)] = (count + 1, first)
        for path, span in self.spans.items():
            v = float(values[path])
            span.low = v if span.low is None else min(span.low, v)
            span.high = v if span.high is None else max(span.high, v)
        if self.rates:
            now = float(values[TIME_NOW])
            for path in self.rates:
                v = float(values[path])
                if path in self.last:
                    t0, v0 = self.last[path]
                    if now > t0:
                        self.rate_max[path] = max(self.rate_max[path], abs(v - v0) / (now - t0))
                self.last[path] = (now, v)

    def finish(self, label: str, result: ScenarioResult) -> None:
        for index, group in enumerate(self.groups):
            checked = self.samples - group.outside
            note = f"отсчётов {self.samples}" + (f", вне охраны {group.outside}" if group.when else "")
            prefix = f"при {' и '.join(w.text for w in group.when)}: " if group.when else ""
            for cond in group.then:
                count, first = self.violations.get((index, cond.text), (0, None))
                ok = None if checked == 0 else count == 0
                text = f"всё время: {prefix}{cond.text}"
                result.checks.append(
                    Check(label, text, ok, first, note if count == 0 else f"{note}, нарушений {count}")
                )
        note = f"отсчётов {self.samples}"
        for path, span in self.spans.items():
            if span.low is None or span.high is None:
                result.checks.append(Check(label, f"размах {path}", None, note="нет отсчётов"))
                continue
            width = span.high - span.low
            result.measured[f"{label}: размах {path}"] = width
            if span.capture:
                self.ctx.captures[f"{span.capture}_min"] = span.low
                self.ctx.captures[f"{span.capture}_max"] = span.high
                result.measured[f"{label}: {span.capture}_min ({path})"] = span.low
                result.measured[f"{label}: {span.capture}_max ({path})"] = span.high
            bounds = []
            if span.max_span is not None:
                bounds.append(f"≤ {span.max_span:g}")
            if span.min_span is not None:
                bounds.append(f"≥ {span.min_span:g}")
            if bounds:
                ok = (span.max_span is None or width <= span.max_span) and (
                    span.min_span is None or width >= span.min_span
                )
                result.checks.append(Check(label, f"размах {path} {' и '.join(bounds)}", ok, width, note))
        for path, limit in self.rates.items():
            rate = self.rate_max[path]
            result.measured[f"{label}: скорость {path}, ед./с"] = rate
            ok = None if self.samples < 2 else rate <= limit
            result.checks.append(Check(label, f"скорость {path} ≤ {limit:g} ед./с", ok, rate, note))


class Runner:
    """Исполнитель шагов сценария поверх ``ScenarioContext``."""

    def __init__(
        self, ctx: ScenarioContext, backend: str, alarms: AlarmView | None = None, feed: EventFeed | None = None
    ) -> None:
        self.ctx = ctx
        self.backend = backend
        self.alarms = alarms
        self.feed = feed
        self.mark_index: dict[str, int] = {}  # метка → число записей курсора до действий шага
        self._feed_polled_at = float("-inf")
        self._feed_pending = False  # курсор журнала ещё не поставлен в этом прогоне

    # --- И0 и завершение ------------------------------------------------------------------------

    def initial_state(self, setup: Mapping[str, Any]) -> None:
        """Исходное состояние И0 (06 §5.2) и отличия проверки из ``[setup]`` (или ключа шага ``init``).

        Наработка — ``run_hours_s`` или И0 (Н1 100 ч, Н2 200 ч, Н3 300 ч). Её пишут, пока насосы стоят (06 §5.2,
        п. 8): станция переводится в «Ручной», насосы — «Стоп» с фейсплейта, затем «Автомат», насосы и LIC101 —
        «Автомат» (06 §5.2, п. 7; ступенчатый
        автомат и ПИД начинают с нуля работающих) и ожидание действующего ступенчатого или ПИД (выход из Float
        и Restart прошлого сценария). После остановки модель снова приводится к уровню ``SimCfg.rLevelInit_m``;
        переходные тревоги И0 квитируются.

        В начале сценария курсор журнала ставится после общей части И0 и до отличий проверки (приток, наработка,
        уровень, способ): события, которые вызывают сами отличия (пуск ведущего при уровне ``level_m``, смена
        способа), попадают в записи сценария. ``init`` посреди сценария курсор не трогает.
        """
        ctx = self.ctx
        skip = bool(setup.get("skip_initial_state", False))
        if not skip:
            ctx.pulse(f"{SIM_CMD}.xResetPlant")
            ctx.clear_faults()
            ctx.pulse(f"{STATION_CMD}.xSetManual")
            for n in range(1, PUMPS + 1):
                ctx.pulse(f"GVL_Hmi.stP10{n}Cmd.xStop")
            ctx.wait(f"{STATION_STS}.uiPumpsRunning = 0", STOP_TIMEOUT_S)
            ctx.pulse(f"{STATION_CMD}.xResetAll")
            ctx.pulse(f"{STATION_CMD}.xAckAll")
            ctx.pulse("GVL_Hmi.xApplyProjectCfg")
            ctx.pulse(f"{STATION_CMD}.xSetAuto")
            ctx.write({f"{FAULT_INJ}.axLocal[{n}]": False for n in range(1, PUMPS + 1)})
            for n in range(1, PUMPS + 1):
                ctx.pulse(f"GVL_Hmi.stP10{n}Cmd.stCommon.xSetAuto")
            # LIC101 и вентилятор В1 в Auto (06 §5.2, п. 7): без этого ПИД не готов (04 §7.4) и «ПИД» работает как
            # ступенчатое, а В1 не пускается по двери, газам и температуре (04 §17); режимы энергонезависимы, после
            # первой загрузки — Manual
            ctx.pulse(f"{PID_CMD}.stCommon.xSetAuto")
            ctx.pulse(f"{FAN_CMD}.stCommon.xSetAuto")
            ctx.wait(f"{STATION_STS}.eControlAct <= E_ControlAct.LevelPid", CONTROL_TIMEOUT_S)
            ctx.pulse(f"{SIM_CMD}.xResetPlant")
        self._start_feed(setup)
        inflow = float(setup.get("inflow_m3h", DEFAULT_INFLOW_M3H))
        ctx.write({f"{SIM_CMD}.xInflowOverride": True, f"{SIM_CMD}.rInflowOverride_m3h": inflow})
        hours = setup.get("run_hours_s", None if skip else DEFAULT_RUN_HOURS_S)
        if hours is not None:
            ctx.write({f"GVL_Persist.stP10{n}Retain.udiOpTime_s": int(v) for n, v in enumerate(hours, 1)})
        if "level_m" in setup:
            ctx.write({f"{SIM_CMD}.rSetLevel_m": float(setup["level_m"])})
            ctx.pulse(f"{SIM_CMD}.xSetLevel")
        method = setup.get("method")
        if method == "Stepped":
            ctx.pulse(f"{STATION_CMD}.xSetStepped")
        elif method == "LevelPid":
            ctx.pulse(f"{STATION_CMD}.xSetLevelPid")
        elif method is not None:
            raise ScenarioError(f"[setup] method = {method!r}: ожидается Stepped или LevelPid")
        if not skip:
            ctx.pulse(f"{STATION_CMD}.xAckAll")

    def _start_feed(self, setup: Mapping[str, Any]) -> None:
        """Курсор журнала сценария — один раз за прогон (с самой старой записи при ``journal_from_start``)."""
        if not self._feed_pending or self.feed is None:
            return
        self._feed_pending = False
        if setup.get("journal_from_start"):
            self.feed.start_at_first()
        else:
            self.feed.start_at_end()
        self._feed_polled_at = self.ctx.clock()

    def teardown(self, teardown: Mapping[str, Any]) -> None:
        if teardown.get("clear_faults", True):
            self.ctx.clear_faults()
        if "inflow_m3h" in teardown:
            self.ctx.write({f"{SIM_CMD}.rInflowOverride_m3h": float(teardown["inflow_m3h"])})
        if "write" in teardown:
            self.ctx.write(dict(teardown["write"]))

    # --- журнал ---------------------------------------------------------------------------------

    def _poll_feed(self) -> None:
        if self.feed is not None:
            self.feed.poll()
            self._feed_polled_at = self.ctx.clock()

    def _tick(self, monitor: Monitor | None) -> Callable[[], None]:
        """Действие каждого периода опроса во время выдержек и ожиданий: отсчёт проверок «всё время» и курсор
        журнала (не реже раза в ``FEED_POLL_MIN_S``)."""

        def tick() -> None:
            if monitor is not None:
                monitor.sample()
            if self.feed is not None and self.ctx.clock() - self._feed_polled_at >= FEED_POLL_MIN_S:
                self._poll_feed()

        return tick

    def _records(self, since: str | None) -> list[EventRecord]:
        """Записи курсора после границы метки ``since`` (без неё — все записи этого прогона)."""
        assert self.feed is not None
        if since is None:
            return list(self.feed.records)
        if since not in self.mark_index:
            raise ScenarioError(f"метка {since!r} не задана (mark) или нет курсора журнала в момент метки")
        return self.feed.records[self.mark_index[since] :]

    def _state_value(self, state: str) -> int:
        states = self.ctx.enums.get("E_AlarmState", {})
        if state not in states:
            raise ScenarioError(f"состояние тревоги {state!r}: нет в E_AlarmState")
        return states[state]

    def _target(self, spec: Mapping[str, Any], kind_alarm: str, kind_event: str, label: str) -> tuple[int, int | None]:
        """Номер записи журнала и состояние (тревога) по ключам ``alarm``/``event`` (или ``from_*``)."""
        if kind_alarm in spec:
            if self.alarms is None:
                raise ScenarioError(f"{label}: проверка по тревоге требует списка тревог")
            state = spec.get("state")
            code = self.ctx.path(str(spec[kind_alarm]))
            return self.alarms.alarm_id(code), (self._state_value(str(state)) if state else None)
        if kind_event in spec:
            return event_id(self.ctx.path(str(spec[kind_event]))), None
        raise ScenarioError(f"{label}: нужен ключ {kind_alarm} или {kind_event}")

    def _poll_until(self, timeout_s: float, probe: Callable[[], EventRecord | None]) -> EventRecord | None:
        deadline = self.ctx.clock() + self.ctx.real_timeout(timeout_s)
        while True:
            self._poll_feed()
            rec = probe()
            if rec is not None or self.ctx.clock() >= deadline:
                return rec
            self.ctx.sleep(self.ctx.poll_s)

    # --- шаги -----------------------------------------------------------------------------------

    def _wait_alarm(
        self, spec: Mapping[str, Any], timeout_s: float, label: str, result: ScenarioResult, tick: Callable[[], None]
    ) -> None:
        if self.alarms is None:
            result.checks.append(Check(label, f"тревога {spec.get('code')}", None, note="нет списка тревог"))
            return
        code, state = self.ctx.path(str(spec["code"])), str(spec.get("state", "ActiveUnack"))
        deadline = self.ctx.clock() + self.ctx.real_timeout(timeout_s)
        actual = self.alarms.state(code)
        while actual != state and self.ctx.clock() < deadline:
            tick()
            self.ctx.sleep(self.ctx.poll_s)
            actual = self.alarms.state(code)
        if actual != state:
            raise ScenarioTimeout(f"тревога {code}: ждали {state} {timeout_s:g} с контура, состояние {actual}")
        result.checks.append(Check(label, f"{code} = {state}", True, actual))

    def _expect_alarm(self, spec: Mapping[str, Any], label: str, result: ScenarioResult) -> None:
        if self.alarms is None:
            result.checks.append(Check(label, f"тревога {spec.get('code')}", None, note="нет списка тревог"))
            return
        code, state = self.ctx.path(str(spec["code"])), str(spec.get("state", "ActiveUnack"))
        actual = self.alarms.state(code)
        result.checks.append(Check(label, f"{code} = {state}", actual == state, actual))

    def _expect_delay(self, spec: Mapping[str, Any], timeout_s: float, label: str, result: ScenarioResult) -> None:
        """Интервал от метки сценария или записи журнала до записи журнала (секунды контура)."""
        feed = self.feed
        if feed is None:
            result.checks.append(Check(label, "задержка по журналу", None, note="нет курсора журнала"))
            return
        target = self._target(spec, "alarm", "event", label)
        # от метки сценария: метка не раньше действия (с точностью до цикла MainTask) и запаздывает не больше
        # чем на период опроса · k — запись журнала может оказаться раньше метки; между записями журнала —
        # без допуска (погрешность — цикл задачи, допуск задаёт сценарий)
        late = early = 0.0
        after_mono: float | None = None
        if "from" in spec:
            name = str(spec["from"])
            start = self.ctx.marks[name]
            early = MAIN_CYCLE_S * self.ctx.time_scale
            late = self.ctx.poll_s * self.ctx.time_scale + early
            if name in self.mark_index:
                since: str | None = name
            else:
                since, after_mono = None, start - late
        else:
            source = self._target(spec, "from_alarm", "from_event", label)
            since = str(spec["since"]) if "since" in spec else None
            rec_from = self._poll_until(
                timeout_s, lambda: find(self._records(since), id=source[0], new_state=source[1])
            )
            if rec_from is None:
                result.checks.append(Check(label, "начальная запись журнала", False, note="не найдена"))
                return
            # записи одного цикла: метка lrMono_s берётся при записи (FB_ScaledClock.Now по системному времени),
            # поэтому запись, сделанная в том же цикле раньше, может быть на доли миллисекунды · k раньше
            # начальной (KNS1.ATS и KNS1.UL1 — PMI-15); полцикла отделяют их от записей прошлого цикла
            start = rec_from.mono_s
            late = SAME_CYCLE_FRACTION * MAIN_CYCLE_S * self.ctx.time_scale
            after_mono = start - late
        rec = self._poll_until(
            timeout_s, lambda: find(self._records(since), id=target[0], new_state=target[1], after_mono_s=after_mono)
        )
        if rec is None:
            result.checks.append(Check(label, "запись журнала", False, note=f"нет записи {target[0]}"))
            return
        delay = rec.mono_s - start
        key = label if label not in result.measured else f"{label} [{target[0]}]"
        result.measured[key] = delay
        ok = delay >= float(spec.get("min_s", 0.0)) - late and (
            "max_s" not in spec or delay <= float(spec["max_s"]) + early
        )
        result.checks.append(Check(label, f"задержка до {target[0]}: {delay:.3f} с", ok, delay))

    def _expect_event(self, spec: Mapping[str, Any], timeout_s: float, label: str, result: ScenarioResult) -> None:
        """Запись журнала (событие станции или переход тревоги) после метки ``since``, при ``value`` — с этим
        значением (номер насоса, параметра, поплавка, число строк)."""
        if self.feed is None:
            result.checks.append(Check(label, "запись журнала", None, note="нет курсора журнала"))
            return
        rid, state = self._target(spec, "alarm", "event", label)
        since = str(spec["since"]) if "since" in spec else None
        value = spec.get("value")
        tol = float(spec.get("value_tol", VALUE_TOL))

        def matches(rec: EventRecord) -> bool:
            return (
                rec.id == rid
                and (state is None or rec.new_state == state)
                and (value is None or abs(rec.value - float(value)) <= tol)
            )

        rec = self._poll_until(timeout_s, lambda: next((r for r in self._records(since) if matches(r)), None))
        text = f"запись {rid}" + (f" со значением {value}" if value is not None else "")
        if rec is None:
            seen = [r.value for r in self._records(since) if r.id == rid]
            result.checks.append(Check(label, text, False, seen, note="нет записи" if not seen else "другое значение"))
            return
        result.checks.append(Check(label, text, True, rec.value))

    def _expect_absent(self, spec: Mapping[str, Any], label: str, result: ScenarioResult) -> None:
        """Нет записи журнала: тревоги в состоянии ``state`` (по умолчанию ActiveUnack) — одной, любой (кроме
        ``except``) или события станции — после метки ``since`` (без неё — с начала прогона)."""
        if self.feed is None:
            result.checks.append(Check(label, "нет записи журнала", None, note="нет курсора журнала"))
            return
        self._poll_feed()
        since = str(spec["since"]) if "since" in spec else None
        records = self._records(since)
        alarm_kind = self.ctx.enums.get("E_EventKind", {}).get("Alarm", 1)
        if spec.get("any_alarm"):
            if self.alarms is None:
                raise ScenarioError(f"{label}: any_alarm требует списка тревог")
            excluded = {self.alarms.alarm_id(self.ctx.path(str(c))) for c in spec.get("except", [])}
            state = self._state_value(str(spec.get("state", "ActiveUnack")))
            bad = [r for r in records if r.kind == alarm_kind and r.id not in excluded and r.new_state == state]
            text = "нет тревог" + (f", кроме {', '.join(spec.get('except', []))}" if spec.get("except") else "")
        elif "alarm" in spec:
            rid, _ = self._target(spec, "alarm", "event", label)
            state = self._state_value(str(spec.get("state", "ActiveUnack")))
            bad = [r for r in records if r.id == rid and r.new_state == state]
            text = f"нет {spec['alarm']} ({spec.get('state', 'ActiveUnack')})"
        else:
            rid, _ = self._target(spec, "alarm", "event", label)
            bad = [r for r in records if r.id == rid]
            text = f"нет {spec['event']}"
        codes = [self.alarms.code_of(r.id) if self.alarms is not None else str(r.id) for r in bad[:5]]
        result.checks.append(Check(label, text, not bad, codes or None))

    def _expect_log_order(self, label: str, result: ScenarioResult) -> None:
        """Записи журнала этого прогона: номера подряд, время процесса и UTC не убывают (сброс ПЛК — новый отсчёт)."""
        if self.feed is None:
            result.checks.append(Check(label, "порядок журнала", None, note="нет курсора журнала"))
            return
        self._poll_feed()
        records = self.feed.records
        bad: tuple[int, int] | None = None
        for prev, cur in itertools.pairwise(records):
            if cur.seq < prev.seq:
                continue  # журнал начат заново (сброс, перезапуск ПЛК)
            utc_back = cur.utc_ms != 0 and prev.utc_ms != 0 and cur.utc_ms < prev.utc_ms
            if cur.seq != prev.seq + 1 or cur.mono_s < prev.mono_s or utc_back:
                bad = (prev.seq, cur.seq)
                break
        note = f"записей {len(records)}"
        result.checks.append(Check(label, "время записей журнала не убывает", bad is None and bool(records), bad, note))

    def run_steps(
        self, steps: Sequence[Mapping[str, Any]], default_timeout_s: float, result: ScenarioResult, prefix: str = ""
    ) -> None:
        for index, step in enumerate(steps, 1):
            label = f"{prefix}{index}" + (f" ({step['note']})" if "note" in step else "")
            self._run_step(step, label, default_timeout_s, result)

    def _run_step(self, step: Mapping[str, Any], label: str, default_timeout_s: float, result: ScenarioResult) -> None:
        ctx = self.ctx
        timeout = float(step.get("timeout_s", default_timeout_s))
        if "time_scale" in step:
            ctx.set_time_scale(float(step["time_scale"]))
        if "init" in step:
            self.initial_state(dict(step["init"]))
        if "mark" in step and self.feed is not None:
            # граница поиска записей журнала для этой метки — до действий шага
            self._poll_feed()
            self.mark_index[str(step["mark"])] = len(self.feed.records)
        if "reset" in step:
            try:
                ctx.client.reset(step["reset"])
            except NotSupportedError as exc:
                result.checks.append(Check(label, f"сброс {step['reset']}", None, note=str(exc)))
                return
        if "write" in step:
            ctx.write(step["write"])
        for path in as_list(step.get("pulse")):
            ctx.pulse(path, timeout)
        if "mark" in step:
            ctx.mark(str(step["mark"]))
        monitored = any(k in step for k in ("during", "during_if", "during_span", "during_rate"))
        monitor = Monitor(ctx, step) if monitored else None
        tick = self._tick(monitor)
        try:
            if monitor is not None:
                monitor.sample()
            if "hold_s" in step:
                ctx.hold(float(step["hold_s"]), tick)
            if "wait" in step:
                actual = ctx.wait(str(step["wait"]), timeout, tick)
                result.checks.append(Check(label, str(step["wait"]), True, actual))
            for spec in as_list(step.get("wait_alarm")):
                self._wait_alarm(spec, timeout, label, result, tick)
        finally:
            if monitor is not None:
                monitor.finish(label, result)
        if "capture" in step:  # после выдержек и ожиданий: значение «когда условие шага выполнено»
            ctx.capture(step["capture"])
        for expr in as_list(step.get("expect")):
            ok, actual = ctx.check(str(expr))
            result.checks.append(Check(label, str(expr), ok, actual))
        for spec in as_list(step.get("expect_alarm")):
            self._expect_alarm(spec, label, result)
        for spec in as_list(step.get("expect_delay")):
            self._expect_delay(spec, timeout, label, result)
        for spec in as_list(step.get("expect_event")):
            self._expect_event(spec, timeout, label, result)
        for spec in as_list(step.get("expect_absent")):
            self._expect_absent(spec, label, result)
        if step.get("expect_log_order"):
            self._expect_log_order(label, result)
        if "manual" in step:
            result.checks.append(Check(label, str(step["manual"]), None, note="вручную: отмечает инженер"))
        if "not_checked" in step:
            result.checks.append(Check(label, str(step["not_checked"]), None, note="не проверяется сценарием"))
        if "repeat" in step:
            for n in range(int(step["repeat"])):
                self.run_steps(step["steps"], default_timeout_s, result, f"{label}.{n + 1}.")
        self._poll_feed()

    def run(self, scenario: Scenario) -> ScenarioResult:
        result = ScenarioResult(
            scenario.id,
            scenario.title,
            self.backend,
            scenario.time_scale,
            manual=list(scenario.manual),
            mode=scenario.mode,
        )
        if self.backend not in scenario.backends:
            result.checks.append(Check("—", "исполнитель", None, note=f"сценарий не для исполнителя {self.backend}"))
            return result
        result.started = dt.datetime.now().isoformat(timespec="seconds")
        clock0 = self.ctx.clock()
        process0 = self._process_time()
        try:
            self.ctx.set_time_scale(scenario.time_scale)
            self._feed_pending = True
            self.initial_state(scenario.setup)
            self._start_feed(scenario.setup)  # если И0 подменён (тесты) или курсора ещё нет
            self.run_steps(scenario.steps, scenario.timeout_s, result)
        except (ScenarioTimeout, ScenarioError, KeyError) as exc:
            result.error = str(exc)
        except Exception as exc:  # пропуск журнала, литерал, обрыв связи: итог сценария — с ошибкой, не исключение
            result.error = f"{type(exc).__name__}: {exc}"
        finally:
            result.marks = dict(self.ctx.marks)
            try:
                self.teardown(scenario.teardown)
            except Exception as exc:  # завершение не должно прятать итог шагов
                result.error = result.error or f"завершение: {exc}"
            result.real_s = round(self.ctx.clock() - clock0, 1)
            process1 = self._process_time()
            if process0 is not None and process1 is not None and process1 >= process0:
                result.process_s = round(process1 - process0, 1)
        return result

    def _process_time(self) -> float | None:
        """Время контура ``lrMainNow_s`` (для длительности прогона); ошибка чтения — None."""
        try:
            return float(self.ctx.client.read([TIME_NOW])[0])
        except Exception:
            return None
