"""Файлы сценариев ПМИ без ПЛК (CI, DESIGN, раздел 14.3): схема, номер, ускорение и вид исполнения по 06_PMI,
приложение А (39 ↔ 39); пути переменных существуют (объявления src/, DESIGN и снимок plc-process-lib), запись —
только туда, где символьная конфигурация сборки sim даёт ReadWrite; значения записей и литералы выражений
подходят к объявленному типу (BOOL, целые, REAL, TIME — литерал ``T#…``, перечисление того же типа); коды тревог —
из 05_alarm_list.csv, события — ``KNS1.E<код>`` из ``E_StationEvent``; подстановки ``{…}`` используют только
значения, захваченные раньше (``capture``, ``mark``, ``during_span.capture``); допуск задержек между записями
журнала — не меньше ±1 цикла MainTask при действующем k (06 §5.3). Подстановки в путях перебираются номерами
насосов 1…3.
"""

from __future__ import annotations

import json
import re
from collections import Counter
from pathlib import Path
from typing import Any

import pytest

import check_docs_consistency as C
import symbol_config as S
from kns_scenarios.alarms import load_alarm_list
from kns_scenarios.client import PLACEHOLDER_RE, placeholder_names
from kns_scenarios.context import _EXPR_RE, _LOCAL_RE
from kns_scenarios.enums import ENUMS
from kns_scenarios.journal import STATION_EVENT_BASE
from kns_scenarios.scenario import MAIN_CYCLE_S, TIME_SCALE_RANGE, Scenario, as_list, load_scenario
from kns_scenarios.values import LiteralError, parse_literal

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
PMI_FILES = sorted((HERE / "pmi").glob("PMI-*.toml"))
FILES = sorted([*(HERE / "examples").glob("PMI-*.toml"), *PMI_FILES])
PMI_COUNT = 39  # 06_PMI, приложение А
# 06, приложение А, колонка «Вид»: 34 проверки — авто, 5 — авто + ручн. (PMI-01, 08, 35, 36, 37), ручных нет
EXPECTED_MODES = {"auto": 34, "auto+manual": 5}
PUMPS = (1, 2, 3)
INT_TYPES = frozenset(
    {"SINT", "USINT", "INT", "UINT", "DINT", "UDINT", "LINT", "ULINT", "BYTE", "WORD", "DWORD", "LWORD"}
)
UNSIGNED_TYPES = frozenset({"USINT", "UINT", "UDINT", "ULINT", "BYTE", "WORD", "DWORD", "LWORD"})
REAL_TYPES = frozenset({"REAL", "LREAL"})
STATION_EVENTS = set(ENUMS["E_StationEvent"].values())
ALARM_STATES = set(ENUMS["E_AlarmState"])
_ENUM_LIT = re.compile(r"^(?:PL\.)?(?P<type>E_\w+)\.\w+$")
_EVENT_RE = re.compile(r"^KNS1\.E(?P<code>\d+)$")


def symbol_index() -> tuple[C.StIndex, dict[str, C.Var]]:
    """Объявления для разрешения путей: снимок библиотеки, DESIGN (объекты других команд), src/."""
    idx = C.StIndex.from_json(json.loads(C.LIB_SNAPSHOT.read_text(encoding="utf-8")))
    idx.merge(C.design_index(C.Doc.load(ROOT / "docs" / "DESIGN.md")))
    for path in sorted((ROOT / "src").rglob("*.st")):
        if path.name.endswith((".dut.st", ".gvl.st", ".pvl.st")):
            idx.merge(C.parse_st(path.read_text(encoding="utf-8"), path.name.split(".")[0]))
    return idx, idx.gvls.get("GVL_Const", {})


INDEX, CONSTS = symbol_index()
RULES_DATA = json.loads(S.RULES_FILE.read_text(encoding="utf-8"))
RULES = S.load_rules(RULES_DATA, "sim")
TYPE_RULES = S.load_type_rules(RULES_DATA)
ALARMS = load_alarm_list()


def appendix() -> dict[str, tuple[float, str]]:
    """Номер → (k, вид исполнения) из приложения А 06_PMI."""
    text = (ROOT / "docs" / "06_PMI.md").read_text(encoding="utf-8")
    part = text[text.index("## Приложение А") :]
    out: dict[str, tuple[float, str]] = {}
    for m in re.finditer(r"^\| (PMI-\d\d) \|[^|\n]*\| (\d+) \|[^|\n]*\|[^|\n]*\| ([^|\n]+?) \|$", part, re.MULTILINE):
        view = m.group(3)
        mode = "manual" if view.startswith("ручн") else ("auto+manual" if "ручн" in view else "auto")
        out[m.group(1)] = (float(m.group(2)), mode)
    return out


def pmi_table() -> dict[str, float]:
    """Номер → k из приложения А 06_PMI."""
    return {key: k for key, (k, _mode) in appendix().items()}


def expand(text: str) -> list[str]:
    """Подстановки {…} номерами насосов 1…3 (как check_docs_consistency для P10n)."""
    if not PLACEHOLDER_RE.search(text):
        return [text]
    return [PLACEHOLDER_RE.sub(str(n), text) for n in PUMPS]


def writable(path: str) -> bool:
    """Запись по пути разрешена символами сборки sim: переменная ReadWrite и, если у её типа есть правило полей,
    поле первого уровня тоже ReadWrite (DESIGN, раздел 13)."""
    parts = re.split(r"\.", re.sub(r"\[[^\]]*\]", "", path))
    gvl, var = parts[0], parts[1]
    if S.access_for(RULES, gvl, var) != "ReadWrite":
        return False
    decl = INDEX.gvls.get(gvl, {}).get(var)
    if decl is None or len(parts) < 3 or decl.type is None:
        return True
    access = S.member_access(TYPE_RULES, decl.type.split(".")[-1], parts[2])
    return access in (None, "ReadWrite")


def declared_type(path: str) -> str | None:
    """Объявленный тип пути (без ``PL.``); None — путь проверен не до конца (тип вне индекса)."""
    res = C.resolve_path(path, INDEX, CONSTS)
    if not res.ok or not res.verified or not res.type:
        return None
    typ = C.base_type_name(res.type)
    return typ if typ.startswith("E_") else typ.split("(")[0].strip().upper()


def literal_kind(value: Any) -> str:
    """Вид значения записи или литерала выражения: bool, int, real, time, ltime, string, enum:E_X, any."""
    if isinstance(value, bool):
        return "bool"
    if isinstance(value, int):
        return "int"
    if isinstance(value, float):
        return "real"
    text = str(value).strip()
    if PLACEHOLDER_RE.search(text):
        return "any"
    parsed = parse_literal(text, ENUMS)  # LiteralError — неизвестное перечисление, тип, формат длительности
    enum = _ENUM_LIT.match(text)
    if enum is not None:
        return f"enum:{enum.group('type')}"
    upper = text.upper()
    if upper.startswith(("T#", "TIME#")):
        return "time"
    if upper.startswith(("LT#", "LTIME#")):
        return "ltime"
    return literal_kind(parsed)


def type_error(path: str, value: Any, op: str = "=") -> str | None:
    """Несовпадение вида значения с объявленным типом пути; None — подходит или тип неизвестен."""
    typ = declared_type(path)
    kind = literal_kind(value)
    if typ is None or kind == "any":
        return None
    if op in ("&", "!&"):
        return None if typ in INT_TYPES and kind == "int" else f"маска {op}: {path} ({typ}) и {value!r}"
    if typ == "BOOL":
        ok = kind == "bool"
    elif typ in INT_TYPES:
        ok = kind == "int" and not (typ in UNSIGNED_TYPES and int(parse_literal(str(value), ENUMS)) < 0)
    elif typ in REAL_TYPES:
        ok = kind in ("int", "real")
    elif typ == "TIME":
        ok = kind == "time"
    elif typ == "LTIME":
        ok = kind == "ltime"
    elif typ.startswith("E_"):
        ok = kind == f"enum:{typ}"
    elif typ.startswith("STRING"):
        ok = kind == "string"
    else:
        return None
    return None if ok else f"{path}: тип {typ}, значение {value!r} ({kind})"


def code_error(code: str) -> str | None:
    for c in expand(code):
        if c not in ALARMS:
            return f"тревоги {c} нет в 05_alarm_list.csv"
    return None


def event_error(code: str) -> str | None:
    m = _EVENT_RE.match(code)
    if m is None or int(m.group("code")) not in STATION_EVENTS:
        return f"событие {code}: ожидается KNS1.E<код> из E_StationEvent ({STATION_EVENT_BASE} + код)"
    return None


class Checker:
    """Проверка одного сценария: пути, запись, типы, коды, подстановки, допуски — список ошибок."""

    def __init__(self, sc: Scenario) -> None:
        self.sc = sc
        self.errors: list[str] = []
        self.defined: set[str] = set()
        self.marks: set[str] = set()
        self.k = sc.time_scale

    def err(self, where: str, text: str | None) -> None:
        if text:
            self.errors.append(f"{self.sc.id}, {where}: {text}")

    def names(self, where: str, text: str, defined: set[str]) -> None:
        """Подстановки текста используют только захваченные раньше значения."""
        for m in PLACEHOLDER_RE.finditer(text):
            try:
                missing = placeholder_names(m.group(1)) - defined
            except SyntaxError:
                self.err(where, f"подстановка {m.group(0)} не разобрана")
                continue
            self.err(where, f"подстановка {m.group(0)}: не захвачено {sorted(missing)}" if missing else None)

    def path(self, where: str, template: str, write: bool = False) -> None:
        for p in expand(template):
            res = C.resolve_path(p, INDEX, CONSTS)
            self.err(where, None if res.ok else f"путь {p}: {res.message}")
            if write:
                self.err(where, None if writable(p) else f"запись в {p} закрыта символами (sim)")

    def expr(self, where: str, expr: str, defined: set[str]) -> None:
        self.names(where, expr, defined)
        if expr.lstrip().startswith(("{", "TRUE", "FALSE")) or _LOCAL_RE.match(expr):
            sample = PLACEHOLDER_RE.sub("1", expr)
            m = _LOCAL_RE.match(sample)
            if m is None:
                self.err(where, f"выражение «{expr}»: ожидается «{{значение}} оператор литерал»")
                return
            try:
                parse_literal(m.group("lit"), ENUMS)
            except LiteralError as exc:
                self.err(where, str(exc))
            return
        m = _EXPR_RE.match(expr)
        if m is None:
            self.err(where, f"выражение «{expr}» не разобрано")
            return
        self.path(where, m.group("path"))
        for p in expand(m.group("path")):
            try:
                self.err(where, type_error(p, m.group("lit"), m.group("op")))
            except LiteralError as exc:
                self.err(where, str(exc))

    def mark_ref(self, where: str, name: Any) -> None:
        self.err(where, None if str(name) in self.marks else f"метка {name!r} не задана раньше (mark)")

    def delay(self, where: str, spec: dict[str, Any], defined: set[str]) -> None:
        for key in ("alarm", "from_alarm"):
            if key in spec:
                self.names(where, str(spec[key]), defined)
                self.err(where, code_error(str(spec[key])))
        for key in ("event", "from_event"):
            if key in spec:
                self.err(where, event_error(str(spec[key])))
        if "state" in spec:
            self.err(where, None if spec["state"] in ALARM_STATES else f"состояние {spec['state']!r}")
        if "from" in spec:
            self.mark_ref(where, spec["from"])
        elif "since" in spec:
            self.mark_ref(where, spec["since"])
        if ("from_alarm" in spec or "from_event" in spec) and "max_s" in spec:
            width = float(spec["max_s"]) - float(spec.get("min_s", 0.0))
            need = 2 * MAIN_CYCLE_S * self.k - 1e-9
            self.err(
                where, None if width >= need else f"допуск {width:g} с меньше ±1 цикла MainTask при k = {self.k:g}"
            )

    def record_ref(self, where: str, spec: dict[str, Any], defined: set[str]) -> None:
        if "alarm" in spec:
            self.names(where, str(spec["alarm"]), defined)
            self.err(where, code_error(str(spec["alarm"])))
        if "event" in spec:
            self.err(where, event_error(str(spec["event"])))
        for code in spec.get("except", []):
            self.err(where, code_error(str(code)))
        if "state" in spec:
            self.err(where, None if spec["state"] in ALARM_STATES else f"состояние {spec['state']!r}")
        if "since" in spec:
            self.mark_ref(where, spec["since"])
        if not any(k in spec for k in ("alarm", "event", "any_alarm")):
            self.err(where, "нужен alarm, event или any_alarm")

    def step(self, where: str, step: dict[str, Any]) -> None:
        before = set(self.defined)
        if "time_scale" in step:
            self.k = float(step["time_scale"])
            lo, hi = TIME_SCALE_RANGE
            self.err(where, None if lo <= self.k <= hi else f"time_scale {self.k:g} вне {TIME_SCALE_RANGE}")
        if self.sc.mode == "auto" and "manual" in step:
            self.err(where, "ручная часть (manual) в сценарии с видом «авто»")
        for path, value in dict(step.get("write", {})).items():
            self.names(where, path, before)
            self.path(where, path, write=True)
            if isinstance(value, str):
                self.names(where, value, before)
            for p in expand(path):
                try:
                    self.err(where, type_error(p, value))
                except LiteralError as exc:
                    self.err(where, str(exc))
        for path in as_list(step.get("pulse")):
            self.names(where, path, before)
            self.path(where, path, write=True)
            for p in expand(path):
                typ = declared_type(p)
                self.err(where, None if typ in (None, "BOOL") else f"импульс {p}: тип {typ}, нужен BOOL")
        if "mark" in step:
            self.marks.add(str(step["mark"]))
            self.defined.add(str(step["mark"]))
        for name, path in dict(step.get("capture", {})).items():
            self.names(where, path, before)
            self.path(where, path)
            self.defined.add(str(name))
        now = set(self.defined)
        for key in ("wait", "expect", "during"):
            for expr in as_list(step.get(key)):
                self.expr(where, str(expr), now)
        for group in as_list(step.get("during_if")):
            for expr in as_list(group.get("when")) + as_list(group.get("then")):
                self.expr(where, str(expr), now)
        for key in ("during_span", "during_rate"):
            for path, spec in dict(step.get(key, {})).items():
                self.names(where, path, now)
                self.path(where, path)
                for p in expand(path):
                    typ = declared_type(p)
                    numeric = typ is None or typ in INT_TYPES | REAL_TYPES | {"BOOL"}
                    self.err(where, None if numeric else f"{key} {p}: тип {typ} не числовой")
                if key == "during_span" and isinstance(spec, dict) and "capture" in spec:
                    self.defined |= {f"{spec['capture']}_min", f"{spec['capture']}_max"}
        for key in ("wait_alarm", "expect_alarm"):
            for spec in as_list(step.get(key)):
                self.names(where, str(spec.get("code", "")), now)
                self.err(where, code_error(str(spec.get("code", ""))))
                state = spec.get("state", "ActiveUnack")
                self.err(where, None if state in ALARM_STATES else f"состояние {state!r}")
        for spec in as_list(step.get("expect_delay")):
            self.delay(where, spec, now)
        for key in ("expect_event", "expect_absent"):
            for spec in as_list(step.get(key)):
                self.record_ref(where, spec, now)
        for i, sub in enumerate(step.get("steps", []), 1):
            self.step(f"{where}.{i}", sub)

    def run(self) -> list[str]:
        for i, step in enumerate(self.sc.steps, 1):
            self.step(f"шаг {i}" + (f" ({step['note']})" if "note" in step else ""), step)
        return self.errors


def test_writable_respects_member_rules() -> None:
    assert writable("GVL_Log.stEventFeed.udiFromSeq") and writable("GVL_Log.stEventView.uiPage")
    assert not writable("GVL_Log.stEventFeed.udiSeqLast") and not writable("GVL_Log.stEventView.astRow[1].udiSeq")
    assert writable("GVL_Sim.stFaultInj.axVfdFault[2]") and not writable("GVL_IO.xLS102")


def test_type_rules_catch_wrong_values() -> None:
    assert type_error("GVL_Sim.stFaultInj.axVfdFault[2]", True) is None
    assert type_error("GVL_Sim.stFaultInj.axVfdFault[2]", 1) is not None
    assert type_error("GVL_Sim.stFaultInj.aeAiFault[1]", "E_SimAiFault.WireBreak") is None
    assert type_error("GVL_Sim.stFaultInj.aeAiFault[1]", "E_SimFloatStuck.None") is not None
    assert type_error("GVL_Persist.stStationCfg.tMaxContRun", "T#10M") is None
    assert type_error("GVL_Persist.stStationCfg.tMaxContRun", 600) is not None
    assert type_error("GVL_Sim.stSimCmd.rInflowOverride_m3h", 180) is None
    assert type_error("GVL_Station.stStationSts.wState", "16#0400", "&") is None
    assert type_error("GVL_Station.stStationSts.rLevel_m", "1", "&") is not None
    assert type_error("GVL_Station.stStationSts.uiPumpsRunning", -1) is not None
    with pytest.raises(LiteralError):
        literal_kind("T#5X")


@pytest.mark.parametrize("path", FILES, ids=[f.parent.name + "/" + f.stem for f in FILES])
def test_scenario_file(path: Path) -> None:
    sc = load_scenario(path)
    table = appendix()
    assert sc.id == path.stem, "имя файла = номер проверки"
    assert sc.id in table, f"{sc.id} нет в приложении А 06_PMI.md"
    k, mode = table[sc.id]
    assert sc.time_scale == k, f"k = {sc.time_scale}, в приложении А — {k}"
    if path.parent.name == "pmi":
        assert sc.mode == mode, f"вид {sc.mode}, в приложении А — {mode}"
        assert bool(sc.manual) == (sc.mode != "auto"), "ручные части (manual) — только у вида «авто + ручн.»"
    errors = Checker(sc).run()
    assert not errors, "\n".join(errors)


def test_pmi_catalogue_complete() -> None:
    ids = {f.stem for f in PMI_FILES}
    assert ids == set(appendix()) and len(ids) == PMI_COUNT, "каждому пункту 06 — файл сценария"
    modes = Counter(load_scenario(f).mode for f in PMI_FILES)
    assert dict(modes) == EXPECTED_MODES, f"автоматизированных и частично ручных: {dict(modes)}"
