"""Действия и ожидания сценария поверх клиента ПЛК (DESIGN, раздел 14.3; 06_PMI, разделы 5.2–5.4).

Время в сценариях — время контура: ускорение k (``GVL_Sim.stSimCfg.rTimeScale``) действует на весь
замкнутый контур, поэтому выдержки логики в секундах контура одинаковы при любом k. Таймаут ожидания
в секундах контура исполнитель делит на k и добавляет запас на задержку опроса (``margin_s``).
Моменты действий сценария — ``GVL_Time.lrMainNow_s`` сразу после записи (``mark``); метка доступна и как
значение подстановки ``{имя}`` — так сценарий сравнивает интервалы между своими наблюдениями
(``{t_off-t_low} >= 4.7``). Выражение, у которого после подстановки слева число, а не путь, сравнивается без
чтения ПЛК.
"""

from __future__ import annotations

import re
import time
from collections.abc import Callable, Mapping
from dataclasses import dataclass, field

from kns_scenarios.client import PlcClient, substitute
from kns_scenarios.values import EnumTable, PlcValue, compare, parse_literal

TIME_NOW = "GVL_Time.lrMainNow_s"
TIME_SCALE = "GVL_Sim.stSimCfg.rTimeScale"
FAULT_INJ = "GVL_Sim.stFaultInj"
SIM_CMD = "GVL_Sim.stSimCmd"
STATION_CMD = "GVL_Station.stStationCmd"
STATION_STS = "GVL_Station.stStationSts"
PID_CMD = "GVL_Station.stLIC101Cmd"
FAN_CMD = "GVL_Hmi.stV1Cmd"
CMD_SEQ = STATION_STS + ".uiCmdSeq"
DEVICES = "GVL_Devices"
TIME_SCALE_MAX = 50.0  # SIM_TIME_SCALE_MAX (DESIGN, раздел 2)

_OP = r"(?P<op><>|<=|>=|!&|=|<|>|&)"
# path оператор литерал; путь может содержать индексы [..] и подстановки {имя}
_EXPR_RE = re.compile(r"^\s*(?P<path>[A-Za-z_][\w.{}]*(?:\[[^\]]+\][\w.{}]*)*)\s*" + _OP + r"\s*(?P<lit>.+?)\s*$")
# число оператор литерал: левая часть — значение сценария после подстановки ({a-b} >= 5), ПЛК не читается
_LOCAL_RE = re.compile(
    r"^\s*(?P<lhs>(?i:TRUE|FALSE)|[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?)\s*" + _OP + r"\s*(?P<lit>.+?)\s*$"
)
# поля ST_StationSts, которые читает station_status (DESIGN, раздел 3.1)
STATION_FIELDS = (
    "eMode",
    "eMethod",
    "eControlAct",
    "eNe107",
    "wState",
    "wCfgErr",
    "uiPumpsRequired",
    "uiPumpsRunning",
    "uiPumpsAvailable",
    "uiLeadPump",
    "uiCmdSeq",
    "wAlmActive",
    "wAlmUnack",
    "ePrioUnack",
    "rLevel_m",
    "rLevelSp_m",
    "rSpeedSp_pct",
    "udiEventSeq",
)
# общий заголовок состояния устройства (ST_DeviceSts библиотеки) и состояние двигателя
DEVICE_FIELDS = (
    "eMode",
    "eNe107",
    "eCmdResult",
    "uiCmdSeq",
    "wStatus",
    "wFault",
    "wWarning",
    "wAlmActive",
    "wAlmUnack",
)


class ScenarioTimeout(TimeoutError):
    """Условие не выполнилось за таймаут (в тексте — условие, таймаут контура и последнее значение)."""


class ExpressionError(ValueError):
    """Выражение ожидания не разобрано."""


@dataclass(frozen=True)
class Condition:
    """Условие ``путь оператор литерал`` (литерал уже разобран) или сравнение значений сценария (``local``)."""

    path: str
    op: str
    expected: PlcValue
    text: str
    local: PlcValue | None = None  # левая часть — значение сценария, путь пуст


@dataclass
class ScenarioContext:
    """Клиент, ускорение и захваченные значения одного прогона сценария."""

    client: PlcClient
    time_scale: float = 1.0
    poll_s: float = 0.25
    margin_s: float = 2.0
    enums: EnumTable = field(default_factory=dict)
    captures: dict[str, PlcValue] = field(default_factory=dict)
    marks: dict[str, float] = field(default_factory=dict)
    clock: Callable[[], float] = time.monotonic
    sleep: Callable[[float], None] = time.sleep

    # --- время ----------------------------------------------------------------------------------

    def real_timeout(self, process_s: float) -> float:
        """Таймаут в секундах контура → реальные секунды с запасом на опрос."""
        return process_s / max(self.time_scale, 1.0) + self.margin_s

    def hold(self, process_s: float, tick: Callable[[], None] | None = None) -> None:
        """Выдержка в секундах контура; с ``tick`` — порциями периода опроса, ``tick`` после каждой (проверки
        «всё время», курсор журнала)."""
        real_s = process_s / max(self.time_scale, 1.0)
        if tick is None:
            self.sleep(real_s)
            return
        end = self.clock() + real_s
        while (remaining := end - self.clock()) > 0:
            self.sleep(min(self.poll_s, remaining))
            tick()

    def set_time_scale(self, k: float) -> None:
        """Ускорение всего контура (1…SIM_TIME_SCALE_MAX)."""
        k = min(max(float(k), 1.0), TIME_SCALE_MAX)
        self.client.write({TIME_SCALE: k})
        self.time_scale = k

    def mark(self, name: str | None = None) -> float:
        """Время процесса MainTask (``lrMainNow_s``) — метка действия сценария."""
        now = float(self.read1(TIME_NOW))
        if name:
            self.marks[name] = now
            self.captures[name] = now  # {имя} в выражениях: интервалы между наблюдениями сценария
        return now

    # --- чтение, запись, условия ----------------------------------------------------------------

    def path(self, template: str) -> str:
        return substitute(template, self.captures)

    def read1(self, path: str) -> PlcValue:
        return self.client.read([self.path(path)])[0]

    def write(self, values: Mapping[str, PlcValue | str]) -> None:
        """Пакет записи; ключи — пути с подстановками, значения — литералы или значения Python."""
        self.client.write(
            {
                self.path(p): parse_literal(self.path(v) if isinstance(v, str) else v, self.enums)
                for p, v in values.items()
            }
        )

    def capture(self, names: Mapping[str, str]) -> dict[str, PlcValue]:
        """Запомнить значения путей под именами (для подстановок ``{имя}``)."""
        paths = [self.path(p) for p in names.values()]
        values = self.client.read(paths)
        got = dict(zip(names, values, strict=True))
        self.captures.update(got)
        return got

    def condition(self, expr: str) -> Condition:
        text = self.path(expr)
        local = _LOCAL_RE.match(text)  # раньше пути: TRUE/FALSE слева — значение, а не имя переменной
        if local is not None:
            return Condition(
                "",
                local.group("op"),
                parse_literal(local.group("lit"), self.enums),
                expr,
                local=parse_literal(local.group("lhs"), self.enums),
            )
        m = _EXPR_RE.match(text)
        if m is not None:
            return Condition(m.group("path"), m.group("op"), parse_literal(m.group("lit"), self.enums), expr)
        raise ExpressionError(
            f"выражение «{expr}»: ожидается «путь оператор литерал», «путь & маска» или «{{значение}} оператор литерал»"
        )

    def check(self, expr: str) -> tuple[bool, PlcValue]:
        """Проверка «здесь и сейчас»: (выполнено, фактическое значение)."""
        cond = self.condition(expr)
        actual = cond.local if cond.local is not None else self.client.read([cond.path])[0]
        return compare(actual, cond.op, cond.expected), actual

    def wait(self, expr: str, timeout_s: float, tick: Callable[[], None] | None = None) -> PlcValue:
        """Ждать условие не дольше ``timeout_s`` секунд контура; ``ScenarioTimeout`` с последним значением.
        ``tick`` — после каждой неуспешной проверки (проверки «всё время», курсор журнала)."""
        cond = self.condition(expr)
        deadline = self.clock() + self.real_timeout(timeout_s)
        while True:
            actual = cond.local if cond.local is not None else self.client.read([cond.path])[0]
            if compare(actual, cond.op, cond.expected):
                return actual
            if self.clock() >= deadline or cond.local is not None:
                raise ScenarioTimeout(
                    f"«{cond.text}» не выполнено за {timeout_s:g} с контура (k = "
                    f"{self.time_scale:g}); последнее значение {actual!r}"
                )
            if tick is not None:
                tick()
            self.sleep(self.poll_s)

    def wait_until(self, path: str, op: str, expected: PlcValue | str, timeout_s: float) -> PlcValue:
        """То же, что ``wait``, с отдельными путём, операцией и ожидаемым значением."""
        literal = expected if isinstance(expected, str) else repr_literal(expected)
        return self.wait(f"{path} {op} {literal}", timeout_s)

    # --- действия ПМИ ---------------------------------------------------------------------------

    def pulse(self, path: str, timeout_s: float = 10.0) -> None:
        """Импульс: записать TRUE и дождаться, что ПЛК его сбросил; для ``stStationCmd`` — ещё рост
        ``uiCmdSeq`` (команда обработана)."""
        target = self.path(path)
        station = target.startswith(STATION_CMD + ".")
        seq = int(self.read1(CMD_SEQ)) if station else 0
        self.client.write({target: True})
        self.wait(f"{target} = FALSE", timeout_s)
        if station:
            self.wait(f"{CMD_SEQ} <> {seq}", timeout_s)

    def inject(self, field_name: str, value: PlcValue | str, index: int | None = None) -> None:
        """Инъекция отказа модели: ``GVL_Sim.stFaultInj.<поле>[индекс] := значение``."""
        target = f"{FAULT_INJ}.{field_name}" + (f"[{index}]" if index is not None else "")
        self.write({target: value})

    def clear_faults(self) -> None:
        """Снять все инъекции (``SimCmd.xClearFaults``, импульс сбрасывает модель)."""
        self.pulse(f"{SIM_CMD}.xClearFaults")

    def station_status(self) -> dict[str, PlcValue]:
        """Поля ``GVL_Station.stStationSts`` (STATION_FIELDS) одним запросом."""
        values = self.client.read([f"{STATION_STS}.{name}" for name in STATION_FIELDS])
        return dict(zip(STATION_FIELDS, values, strict=True))

    def device_status(self, tag: str, extra: tuple[str, ...] = ()) -> dict[str, PlcValue]:
        """Общий заголовок состояния устройства ``fb<TAG>.stSts.stCommon`` и поля ``stSts`` из ``extra``
        (у насоса — ``eState``, ``rSpeedAct_pct``)."""
        base = f"{DEVICES}.fb{tag}.stSts"
        paths = [f"{base}.stCommon.{name}" for name in DEVICE_FIELDS] + [f"{base}.{name}" for name in extra]
        values = self.client.read(paths)
        return dict(zip((*DEVICE_FIELDS, *extra), values, strict=True))


def repr_literal(value: PlcValue) -> str:
    """Значение Python → литерал выражения (``TRUE``, ``1.5``, ``'текст'``)."""
    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"
    if isinstance(value, str):
        return f"'{value}'"
    return repr(value)
