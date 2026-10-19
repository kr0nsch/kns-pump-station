"""Сценарий ПМИ — декларативный файл TOML и его исполнение (DESIGN, раздел 14.3).

Файл: ``id``, ``title``, ``time_scale``, ``timeout_s`` (таймаут шага по умолчанию, секунды контура),
``backends``, ``manual``, таблица ``[setup]`` (исходное состояние И0 06 §5.2 и отличия проверки), шаги
``[[step]]`` и ``[teardown]``. Ключи шага: ``write``, ``pulse``, ``mark``, ``capture``, ``hold_s``,
``wait``, ``wait_alarm``, ``expect``, ``expect_delay``, ``repeat`` + ``steps``, ``reset``, ``note``,
``timeout_s``. Внутри шага действия выполняются в этом порядке: reset, write, pulse, mark, capture,
hold_s, wait, wait_alarm, expect, expect_delay, repeat (другой порядок — отдельные шаги). Неуспех
``expect`` не прерывает сценарий — отчёт собирает все проверки; таймаут ``wait``
прерывает (дальше проверять нечего). Любая другая ошибка шага (пропуск записей журнала, неверный литерал,
обрыв связи) тоже прерывает сценарий и попадает в отчёт как его ошибка, завершение выполняется всегда.

``expect_delay`` от метки сценария: метка ``lrMainNow_s`` читается после записи, поэтому она не раньше
действия (с точностью до цикла MainTask, в начале которого ``lrMainNow_s`` обновляется) и запаздывает не
больше чем на «период опроса · k». Запись журнала ищется среди записей с номером больше последнего номера
журнала перед записью шага (она может оказаться раньше метки), допуск «период опроса · k» — только для
``min_s``, для ``max_s`` — один цикл MainTask · k: измеренная задержка не больше настоящей.
"""

from __future__ import annotations

import tomllib
from collections.abc import Mapping, Sequence
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from kns_scenarios.alarms import AlarmView
from kns_scenarios.client import NotSupportedError
from kns_scenarios.context import FAULT_INJ, SIM_CMD, STATION_CMD, ScenarioContext, ScenarioTimeout
from kns_scenarios.journal import EventFeed, event_id, find

STEP_KEYS = frozenset(
    {
        "note",
        "write",
        "pulse",
        "mark",
        "capture",
        "hold_s",
        "wait",
        "wait_alarm",
        "expect",
        "expect_delay",
        "repeat",
        "steps",
        "reset",
        "timeout_s",
    }
)
TOP_KEYS = frozenset({"id", "title", "time_scale", "timeout_s", "backends", "manual", "setup", "step", "teardown"})
SETUP_KEYS = frozenset({"method", "level_m", "inflow_m3h", "run_hours_s", "skip_initial_state"})
TEARDOWN_KEYS = frozenset({"clear_faults", "inflow_m3h"})
BACKENDS = frozenset({"opcua", "cds"})
PUMPS = 3  # GVL_Const.STN_PUMP_COUNT
DEFAULT_INFLOW_M3H = 100.0  # 06 §5.2, п. 3
MAIN_CYCLE_S = 0.02  # период MainTask (DESIGN, раздел 12): шаг метки lrMainNow_s
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


def _check_steps(steps: Sequence[Any], where: str) -> None:
    for index, step in enumerate(steps, 1):
        if not isinstance(step, dict):
            raise ScenarioError(f"{where}, шаг {index}: ожидается таблица")
        unknown = sorted(set(step) - STEP_KEYS)
        if unknown:
            raise ScenarioError(f"{where}, шаг {index}: неизвестные ключи {unknown}")
        if "repeat" in step and not isinstance(step.get("steps"), list):
            raise ScenarioError(f"{where}, шаг {index}: repeat без вложенных steps")
        if "steps" in step:
            _check_steps(step["steps"], f"{where}, шаг {index}")


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

    @property
    def verdict(self) -> str:
        if self.error is not None or any(c.ok is False for c in self.checks):
            return FAIL
        if not self.checks or all(c.ok is None for c in self.checks):
            return NOT_CHECKED
        return PASS


class Runner:
    """Исполнитель шагов сценария поверх ``ScenarioContext``."""

    def __init__(
        self, ctx: ScenarioContext, backend: str, alarms: AlarmView | None = None, feed: EventFeed | None = None
    ) -> None:
        self.ctx = ctx
        self.backend = backend
        self.alarms = alarms
        self.feed = feed
        self.mark_seq: dict[str, int] = {}  # метка → последний номер журнала перед записью шага

    # --- И0 и завершение ------------------------------------------------------------------------

    def initial_state(self, setup: Mapping[str, Any]) -> None:
        """Исходное состояние И0 (06 §5.2) и отличия проверки из ``[setup]``."""
        ctx = self.ctx
        if not setup.get("skip_initial_state", False):
            ctx.pulse(f"{SIM_CMD}.xResetPlant")
            ctx.clear_faults()
            ctx.pulse(f"{STATION_CMD}.xResetAll")
            ctx.pulse(f"{STATION_CMD}.xAckAll")
            ctx.pulse("GVL_Hmi.xApplyProjectCfg")
            ctx.pulse(f"{STATION_CMD}.xSetAuto")
            ctx.write({f"{FAULT_INJ}.axLocal[{n}]": False for n in range(1, PUMPS + 1)})
            for n in range(1, PUMPS + 1):
                ctx.pulse(f"GVL_Hmi.stP10{n}Cmd.stCommon.xSetAuto")
        inflow = float(setup.get("inflow_m3h", DEFAULT_INFLOW_M3H))
        ctx.write({f"{SIM_CMD}.xInflowOverride": True, f"{SIM_CMD}.rInflowOverride_m3h": inflow})
        if "level_m" in setup:
            ctx.write({f"{SIM_CMD}.rSetLevel_m": float(setup["level_m"])})
            ctx.pulse(f"{SIM_CMD}.xSetLevel")
        if "run_hours_s" in setup:
            ctx.write(
                {f"GVL_Persist.stP10{n}Retain.udiOpTime_s": int(v) for n, v in enumerate(setup["run_hours_s"], 1)}
            )
        method = setup.get("method")
        if method == "Stepped":
            ctx.pulse(f"{STATION_CMD}.xSetStepped")
        elif method == "LevelPid":
            ctx.pulse(f"{STATION_CMD}.xSetLevelPid")
        elif method is not None:
            raise ScenarioError(f"[setup] method = {method!r}: ожидается Stepped или LevelPid")

    def teardown(self, teardown: Mapping[str, Any]) -> None:
        if teardown.get("clear_faults", True):
            self.ctx.clear_faults()
        if "inflow_m3h" in teardown:
            self.ctx.write({f"{SIM_CMD}.rInflowOverride_m3h": float(teardown["inflow_m3h"])})

    # --- шаги -----------------------------------------------------------------------------------

    def _poll_feed(self) -> None:
        if self.feed is not None:
            self.feed.poll()

    def _wait_alarm(self, spec: Mapping[str, Any], timeout_s: float, label: str, result: ScenarioResult) -> None:
        if self.alarms is None:
            result.checks.append(Check(label, f"тревога {spec.get('code')}", None, note="нет списка тревог"))
            return
        code, state = self.ctx.path(str(spec["code"])), str(spec.get("state", "ActiveUnack"))
        deadline = self.ctx.clock() + self.ctx.real_timeout(timeout_s)
        actual = self.alarms.state(code)
        while actual != state and self.ctx.clock() < deadline:
            self.ctx.sleep(self.ctx.poll_s)
            actual = self.alarms.state(code)
        if actual != state:
            raise ScenarioTimeout(f"тревога {code}: ждали {state} {timeout_s:g} с контура, состояние {actual}")
        result.checks.append(Check(label, f"{code} = {state}", True, actual))

    def _expect_delay(self, spec: Mapping[str, Any], timeout_s: float, label: str, result: ScenarioResult) -> None:
        """Интервал от метки сценария или записи журнала до записи журнала (секунды контура)."""
        feed = self.feed
        if feed is None:
            result.checks.append(Check(label, "задержка по журналу", None, note="нет курсора журнала"))
            return
        states = self.ctx.enums.get("E_AlarmState", {})

        def target_id(kind_alarm: str, kind_event: str) -> tuple[int, int | None] | None:
            if kind_alarm in spec:
                if self.alarms is None:
                    raise ScenarioError(f"{label}: expect_delay по тревоге требует списка тревог")
                state = spec.get("state")
                code = self.ctx.path(str(spec[kind_alarm]))
                return self.alarms.alarm_id(code), (states[str(state)] if state else None)
            if kind_event in spec:
                return event_id(self.ctx.path(str(spec[kind_event]))), None
            return None

        target = target_id("alarm", "event")
        if target is None:
            raise ScenarioError(f"{label}: expect_delay без alarm или event")
        # от метки сценария: метка не раньше действия (с точностью до цикла MainTask) и запаздывает не больше
        # чем на период опроса · k — запись журнала может оказаться раньше метки; между записями журнала —
        # без допуска (погрешность — цикл задачи)
        late = early = 0.0
        after_seq: int | None = None
        after_mono: float | None = None
        if "from" in spec:
            name = str(spec["from"])
            start = self.ctx.marks[name]
            early = MAIN_CYCLE_S * self.ctx.time_scale
            late = self.ctx.poll_s * self.ctx.time_scale + early
            after_seq = self.mark_seq.get(name)
            after_mono = start - late if after_seq is None else None
        else:
            source = target_id("from_alarm", "from_event")
            if source is None:
                raise ScenarioError(f"{label}: expect_delay без from / from_alarm / from_event")
            rec_from = None
            deadline = self.ctx.clock() + self.ctx.real_timeout(timeout_s)
            while rec_from is None and self.ctx.clock() < deadline:
                self._poll_feed()
                rec_from = find(feed.records, id=source[0], new_state=source[1])
                if rec_from is None:
                    self.ctx.sleep(self.ctx.poll_s)
            if rec_from is None:
                result.checks.append(Check(label, "начальная запись журнала", False, note="не найдена"))
                return
            start = rec_from.mono_s
            after_mono = start
        rec = None
        deadline = self.ctx.clock() + self.ctx.real_timeout(timeout_s)
        while rec is None and self.ctx.clock() < deadline:
            self._poll_feed()
            rec = find(feed.records, id=target[0], new_state=target[1], after_mono_s=after_mono, after_seq=after_seq)
            if rec is None:
                self.ctx.sleep(self.ctx.poll_s)
        if rec is None:
            result.checks.append(Check(label, "запись журнала", False, note=f"нет записи {target[0]}"))
            return
        delay = rec.mono_s - start
        result.measured[label] = delay
        ok = delay >= float(spec.get("min_s", 0.0)) - late and (
            "max_s" not in spec or delay <= float(spec["max_s"]) + early
        )
        result.checks.append(Check(label, f"задержка {delay:.3f} с", ok, delay))

    def run_steps(
        self, steps: Sequence[Mapping[str, Any]], default_timeout_s: float, result: ScenarioResult, prefix: str = ""
    ) -> None:
        ctx = self.ctx
        for index, step in enumerate(steps, 1):
            label = f"{prefix}{index}" + (f" ({step['note']})" if "note" in step else "")
            timeout = float(step.get("timeout_s", default_timeout_s))
            if "mark" in step and self.feed is not None:
                # граница поиска записей журнала для expect_delay от этой метки — до действий шага
                self.mark_seq[str(step["mark"])] = self.feed.last_seq()
            if "reset" in step:
                try:
                    ctx.client.reset(step["reset"])
                except NotSupportedError as exc:
                    result.checks.append(Check(label, f"сброс {step['reset']}", None, note=str(exc)))
                    continue
            if "write" in step:
                ctx.write(step["write"])
            if "pulse" in step:
                pulses = step["pulse"] if isinstance(step["pulse"], list) else [step["pulse"]]
                for path in pulses:
                    ctx.pulse(path, timeout)
            if "mark" in step:
                ctx.mark(str(step["mark"]))
            if "capture" in step:
                ctx.capture(step["capture"])
            if "hold_s" in step:
                ctx.hold(float(step["hold_s"]))
            if "wait" in step:
                actual = ctx.wait(str(step["wait"]), timeout)
                result.checks.append(Check(label, str(step["wait"]), True, actual))
            if "wait_alarm" in step:
                self._wait_alarm(step["wait_alarm"], timeout, label, result)
            for expr in step.get("expect", []):
                ok, actual = ctx.check(str(expr))
                result.checks.append(Check(label, str(expr), ok, actual))
            if "expect_delay" in step:
                self._expect_delay(step["expect_delay"], timeout, label, result)
            if "repeat" in step:
                for n in range(int(step["repeat"])):
                    self.run_steps(step["steps"], default_timeout_s, result, f"{label}.{n + 1}.")
            self._poll_feed()

    def run(self, scenario: Scenario) -> ScenarioResult:
        result = ScenarioResult(
            scenario.id, scenario.title, self.backend, scenario.time_scale, manual=list(scenario.manual)
        )
        if self.backend not in scenario.backends:
            result.checks.append(Check("—", "исполнитель", None, note=f"сценарий не для исполнителя {self.backend}"))
            return result
        try:
            self.ctx.set_time_scale(scenario.time_scale)
            self.initial_state(scenario.setup)
            if self.feed is not None:
                self.feed.start_at_end()
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
        return result
