"""Сверка технологических документов КНС-1 между собой и с проектом ПО.

Спецификация проекта требует: «документы 01–08 согласованы: теги, уставки и тексты тревог совпадают».
Скрипт проверяет это автоматически и запускается в CI (pytest — tools_project/test_check_docs_consistency.py).

Источники истины:

- `docs/03_io_list.csv` — теги, устройства, уставки HH/H/L/LL, задержки, параметры;
- `docs/alarms.csv` — список тревог устройств, который выдал генератор iolistgen по тому же перечню;
- `docs/DESIGN.md` — объявления ST: типы, глобальные списки, ФБ, константы `GVL_Const`;
- контракт plc-process-lib 1.0 — снимок `tools_project/data/plc_process_lib.json` (типы, ФБ, константы);
- `docs/04_algorithms.md` — уставки станции, события журнала, тревоги станции;
- `docs/05_alarm_list.csv` — коды, номера, приоритеты и тексты тревог;
- `docs/06_PMI.md` — номера и названия проверок.

Сверяются `docs/01`–`08`, `ARCHITECTURE.md`, `DESIGN.md`, `ASSUMPTIONS.md`, `README.md` и макеты
`docs/hmi/*.svg`; список проверок — `python tools_project/check_docs_consistency.py --list`.

Если рядом лежат репозитории iolistgen и plc-process-lib (переменные `IOLISTGEN_REPO` и `PL_REPO` или
соседние каталоги; у рабочей копии в `_wt/` — на уровень выше), скрипт дополнительно сверяет с ними
сохранённые снимки: перегенерирует перечень и перечитывает исходники библиотеки.

Запуск: `python tools_project/check_docs_consistency.py` — код выхода 1, если есть расхождения.
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import re
import subprocess
import sys
from collections.abc import Callable, Iterable, Iterator, Sequence
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import generate

REPO_ROOT = Path(__file__).resolve().parents[1]
LIB_SNAPSHOT = Path(__file__).resolve().parent / "data" / "plc_process_lib.json"
# Блок станции в GVL_Persist (persist_extra iolistgen, DESIGN, раздел 4.7)
PERSIST_EXTRA = Path(__file__).resolve().parent / "persist_station.txt"

# Документы, которые сверяются (порядок — порядок отчёта)
MD_DOCS = (
    "01_TZ.md",
    "02_functional_diagram.md",
    "04_algorithms.md",
    "06_PMI.md",
    "07_test_protocol.md",
    "08_hmi_spec.md",
    "ARCHITECTURE.md",
    "DESIGN.md",
    "ASSUMPTIONS.md",
)
DOC_SHORT = {
    "01": "01_TZ.md",
    "02": "02_functional_diagram.md",
    "04": "04_algorithms.md",
    "06": "06_PMI.md",
    "07": "07_test_protocol.md",
    "08": "08_hmi_spec.md",
}

# Позиции, которых нет в перечне сигналов, но которые законно встречаются в документах:
# станция и регулятор (D-04), обозначения ПЧ по ГОСТ 2.710
EXTRA_TAGS = frozenset({"KNS1", "LIC101", "UZ1", "UZ2", "UZ3"})
# Буквенно-цифровые обозначения, похожие на позиции приборов, но не позиции
NOT_TAGS = frozenset({"RS485", "PLC210", "ISA101", "IEC61131", "V3"})
# Коды правил линтеров (st_lint STL001, iolistgen IOL104) — не позиции
NOT_TAG_PATTERN = r"(?:STL|IOL)\d{3}"

# Объекты других проектов, которые документы называют (план встраивания проекта 06 и шаблон)
EXTERNAL_OBJECTS = frozenset(
    {
        "PRG_Iiot",  # проект 06 (plc-iiot-stack)
        "GVL_Iiot",
        "GVL_HmiStyle",  # константы палитры WebVisu — предложение 08_hmi_spec, раздел 13
        "FB_Example",  # пример шаблона, удаляется в этапе 0 (DESIGN, раздел 1)
        "ST_ExampleCmd",
        "ST_ExampleSts",
        "F_Clamp",
        "PRG_Main",
        "I_Resettable",
        "PRG_Tests",
        "FB_KnsShim_Test",  # тест заглушки флагмана в проекте 06 (удаляется при встраивании)
    }
)
# Константы проекта 06, которые DESIGN, раздел 17, перечисляет как пересечения при встраивании
EXTERNAL_CONSTANTS = frozenset({"DEV_MODE_OOS", "MOT_FLT_COMM", "MOT_WRN_COMM", "REAL_EXP_MASK"})
EXTERNAL_CONST_PREFIXES = ("ASCII_", "CMD_RESULT_")

PROJECT_CONST_PREFIXES = ("STN_", "KNS_", "SIM_", "LOG_", "ALM_", "VFD_", "V1_ILK", "LIC101_", "TAG_LEN")
LIBRARY_CONST_PREFIXES = ("NE43_", "MOT_", "AI_", "DI_", "DEV_", "PID_", "VLV_", "CV_")

# Разделы 04, которые реализует логика ПО: каждый должен быть назван в заголовке ФБ DESIGN, раздел 6–9
REQUIRED_04_SECTIONS = (
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10.1",
    "10.2",
    "10.3",
    "10.4",
    "10.5",
    "11",
    "12",
    "13",
    "14",
    "15",
    "16",
    "17",
    "18.3",
)

# Биты stStationSts.wState: константа DESIGN → слово, которое должно быть в описании бита в документах
WSTATE_KEYWORDS = {
    "STN_ST_DRY_RUN": "сухой ход",
    "STN_ST_EMERGENCY": "аварийный",
    "STN_ST_FLOAT": "поплав",
    "STN_ST_STEP_FALLBACK": "ступенчат",
    "STN_ST_POWER_LOST": "напряжени",
    "STN_ST_RESTART": "последовательный пуск",
    "STN_ST_ATS": "АВР",
    "STN_ST_NO_RESERVE": "резерв",
    "STN_ST_LACK": "недостаточно",
    "STN_ST_LS102_MASKED": "LS102",
    "STN_ST_LS103_MASKED": "LS103",
    "STN_ST_SIMULATION": "имитаци",
    "STN_ST_HORN": "сирен",
    "STN_ST_COMMON_ALARM": "общая авария",
    "STN_ST_UNACK": "неквитирован",
    "STN_ST_LT_MASKED": "LT101",
}

ELEMENTARY = frozenset(
    {
        "BOOL",
        "BYTE",
        "WORD",
        "DWORD",
        "LWORD",
        "SINT",
        "INT",
        "DINT",
        "LINT",
        "USINT",
        "UINT",
        "UDINT",
        "ULINT",
        "REAL",
        "LREAL",
        "TIME",
        "LTIME",
        "DATE",
        "TOD",
        "DT",
        "STRING",
        "WSTRING",
    }
)
TYPE_SHORT = {
    "AnalogInput": "AnalogInput",
    "DigitalInput": "DigitalInput",
    "Motor": "Motor",
    "MotorVfd": "Motor",
    "Valve": "Valve",
    "ControlValve": "ControlValve",
    "Pid": "Pid",
}
ADAPTER_VARS = (
    ("x{d}_CommOk", "BOOL"),
    ("x{d}_VfdRun", "BOOL"),
    ("x{d}_VfdReady", "BOOL"),
    ("x{d}_VfdFault", "BOOL"),
    ("r{d}_SpeedAct_pct", "REAL"),
    ("r{d}_SpeedRef_pct", "REAL"),
    ("x{d}_VfdQRun", "BOOL"),
    ("x{d}_VfdQReset", "BOOL"),
)
PREFIX_TYPE = (("ui", "UINT"), ("udi", "UDINT"), ("x", "BOOL"), ("r", "REAL"), ("w", "WORD"), ("i", "INT"))

ALARM_PRIORITIES = ("None", "Low", "Medium", "High", "Critical")
# Задержка появления станционной тревоги в 05 = tOnDelay тревоги + выдержка логики (параметр ST_StationCfg)
STATION_LOGIC_DELAY = {"LDEV": "tLdev", "UL": "tUnderload"}


# --------------------------------------------------------------------------------------------------
# Находки
# --------------------------------------------------------------------------------------------------


@dataclass(frozen=True)
class Finding:
    """Расхождение: код проверки, документ, строка (0 — весь документ) и текст."""

    check: str
    doc: str
    line: int
    message: str

    def __str__(self) -> str:
        loc = f"{self.doc}:{self.line}" if self.line else self.doc
        return f"{loc}: [{self.check}] {self.message}"


# --------------------------------------------------------------------------------------------------
# Числа и значения
# --------------------------------------------------------------------------------------------------

_TIME_PART = re.compile(r"(\d+(?:\.\d+)?)(MS|US|NS|D|H|M|S)", re.I)
_TIME_UNIT_S = {"D": 86400.0, "H": 3600.0, "M": 60.0, "S": 1.0, "MS": 1e-3, "US": 1e-6, "NS": 1e-9}
DOC_UNIT_S = {"мс": 1e-3, "с": 1.0, "мин": 60.0, "ч": 3600.0}


def parse_time(literal: str) -> float | None:
    """`T#1H30M`, `LTIME#200MS` → секунды; не литерал времени → None."""
    m = re.fullmatch(r"(?:L?TIME|L?T)#([0-9A-Za-z_.]+)", literal.strip(), re.I)
    if not m:
        return None
    body = m.group(1).replace("_", "")
    total = 0.0
    pos = 0
    for part in _TIME_PART.finditer(body):
        if part.start() != pos:
            return None
        total += float(part.group(1)) * _TIME_UNIT_S[part.group(2).upper()]
        pos = part.end()
    return total if pos == len(body) and pos else None


def doc_number(text: str) -> float | None:
    """Число из документа: «1,60», «−0,09», «4 000» → float; не число → None."""
    t = text.strip().replace("−", "-").replace(" ", "").replace(" ", "").replace(" ", "")
    t = t.replace(",", ".")
    try:
        return float(t)
    except ValueError:
        return None


def st_scalar(value: str) -> float | bool | str:
    """Скалярное значение ST: число, время (с), TRUE/FALSE или литерал перечисления (последняя часть)."""
    v = value.strip()
    t = parse_time(v)
    if t is not None:
        return t
    if v.upper() in ("TRUE", "FALSE"):
        return v.upper() == "TRUE"
    num = re.fullmatch(r"[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?", v.replace("_", ""))
    if num:
        return float(v.replace("_", ""))
    hexm = re.fullmatch(r"16#([0-9A-Fa-f_]+)", v)
    if hexm:
        return float(int(hexm.group(1).replace("_", ""), 16))
    return v.rsplit(".", 1)[-1]


def same_value(a: float | bool | str, b: float | bool | str) -> bool:
    if isinstance(a, bool) or isinstance(b, bool):
        return a == b
    if isinstance(a, float) and isinstance(b, float):
        return abs(a - b) <= 1e-6 * max(1.0, abs(a), abs(b))
    return str(a) == str(b)


# --------------------------------------------------------------------------------------------------
# Markdown
# --------------------------------------------------------------------------------------------------


@dataclass(frozen=True)
class CodeBlock:
    lang: str
    line: int  # номер первой строки содержимого
    text: str


@dataclass(frozen=True)
class Heading:
    line: int
    level: int
    number: str
    title: str


@dataclass
class Table:
    line: int
    header: list[str]
    rows: list[tuple[int, list[str]]]
    section: str


def split_row(line: str) -> list[str]:
    s = line.strip()
    if s.startswith("|"):
        s = s[1:]
    if s.endswith("|") and not s.endswith("\\|"):
        s = s[:-1]
    return [c.strip().replace("\\|", "|") for c in re.split(r"(?<!\\)\|", s)]


class Doc:
    """Документ Markdown: строки, блоки кода, заголовки, таблицы, фрагменты в обратных кавычках."""

    def __init__(self, name: str, text: str) -> None:
        self.name = name
        self.text = text
        self.lines = text.splitlines()
        self.blocks: list[CodeBlock] = []
        self.headings: list[Heading] = []
        self.code_lines: set[int] = set()
        self._scan()

    @classmethod
    def load(cls, path: Path) -> Doc:
        return cls(path.name, path.read_text(encoding="utf-8"))

    def _scan(self) -> None:
        in_code = False
        lang = ""
        start = 0
        buf: list[str] = []
        for no, line in enumerate(self.lines, 1):
            s = line.strip()
            if s.startswith("```"):
                if in_code:
                    self.blocks.append(CodeBlock(lang, start, "\n".join(buf)))
                    in_code = False
                    buf = []
                else:
                    in_code = True
                    lang = s[3:].strip()
                    start = no + 1
                self.code_lines.add(no)
                continue
            if in_code:
                self.code_lines.add(no)
                buf.append(line)
                continue
            m = re.match(r"(#{1,6})\s+(.*)", line)
            if m:
                title = m.group(2).strip()
                num = re.match(r"(\d+(?:\.\d+)*)\.?\s", title + " ")
                self.headings.append(Heading(no, len(m.group(1)), num.group(1) if num else "", title))

    def prose(self) -> Iterator[tuple[int, str]]:
        for no, line in enumerate(self.lines, 1):
            if no not in self.code_lines:
                yield no, line

    def spans(self) -> Iterator[tuple[int, str, str]]:
        """Фрагменты `...` вне блоков кода: (строка, фрагмент, текст после фрагмента)."""
        for no, line in self.prose():
            for m in re.finditer(r"`([^`]+)`", line):
                yield no, m.group(1), line[m.end() :]

    def heading_at(self, line_no: int) -> Heading | None:
        last = None
        for h in self.headings:
            if h.line > line_no:
                break
            last = h
        return last

    def section_numbers(self) -> set[str]:
        return {h.number for h in self.headings if h.number}

    def section_lines(self, number: str) -> list[tuple[int, str]]:
        """Строки раздела с номером `number` (до следующего заголовка того же или старшего уровня)."""
        start = next((h for h in self.headings if h.number == number), None)
        if start is None:
            return []
        end = len(self.lines) + 1
        for h in self.headings:
            if h.line > start.line and h.level <= start.level:
                end = h.line
                break
        return [(no, self.lines[no - 1]) for no in range(start.line + 1, end)]

    def tables(self) -> list[Table]:
        out: list[Table] = []
        lines = self.lines
        no = 1
        while no <= len(lines):
            line = lines[no - 1]
            nxt = lines[no] if no < len(lines) else ""
            if no not in self.code_lines and line.lstrip().startswith("|") and re.match(r"\s*\|\s*:?-{3,}", nxt):
                header = split_row(line)
                h = self.heading_at(no)
                table = Table(no, header, [], h.number if h else "")
                row_no = no + 2
                while row_no <= len(lines) and lines[row_no - 1].lstrip().startswith("|"):
                    table.rows.append((row_no, split_row(lines[row_no - 1])))
                    row_no += 1
                out.append(table)
                no = row_no
                continue
            no += 1
        return out

    def section_tables(self, number: str) -> list[Table]:
        return [t for t in self.tables() if t.section == number]


def cell_names(cell: str) -> list[str]:
    """Имена в обратных кавычках из ячейки таблицы."""
    return re.findall(r"`([^`]+)`", cell)


# --------------------------------------------------------------------------------------------------
# Разбор объявлений ST
# --------------------------------------------------------------------------------------------------


@dataclass
class Var:
    name: str
    type: str
    init: str | None = None
    kind: str = "var"  # var, input, output, inout, property, method, const


@dataclass
class TypeDef:
    name: str
    kind: str  # struct, enum, fb, interface, function, program
    members: dict[str, Var] = field(default_factory=dict)
    values: dict[str, int | None] = field(default_factory=dict)
    base: str | None = None


@dataclass
class StIndex:
    """Символы ST: типы, глобальные списки, константы."""

    types: dict[str, TypeDef] = field(default_factory=dict)
    gvls: dict[str, dict[str, Var]] = field(default_factory=dict)

    def merge(self, other: StIndex) -> None:
        for name, t in other.types.items():
            known = self.types.get(name)
            if known is None:
                self.types[name] = t
            else:
                known.members.update(t.members)
                known.values.update(t.values)
                known.base = known.base or t.base
        for gvl, members in other.gvls.items():
            self.gvls.setdefault(gvl, {}).update(members)

    def type_def(self, type_name: str) -> TypeDef | None:
        name = base_type_name(type_name)
        return self.types.get(name)

    def members_of(self, type_name: str) -> dict[str, Var] | None:
        """Члены типа с наследованием; None — тип неизвестен; {} — элементарный тип или перечисление."""
        name = base_type_name(type_name)
        if name.split("(")[0].upper() in ELEMENTARY or name in ("METHOD", "PROPERTY"):
            return {}
        t = self.types.get(name)
        if t is None:
            return None
        if t.kind == "enum":
            return {}
        members: dict[str, Var] = {}
        chain: list[TypeDef] = []
        seen: set[str] = set()
        cur: TypeDef | None = t
        while cur is not None and cur.name not in seen:
            chain.append(cur)
            seen.add(cur.name)
            cur = self.types.get(base_type_name(cur.base)) if cur.base else None
        for item in reversed(chain):
            members.update(item.members)
        return members

    def to_json(self) -> dict[str, Any]:
        return {
            "types": {
                n: {
                    "kind": t.kind,
                    "base": t.base,
                    "members": {m: [v.type, v.init, v.kind] for m, v in sorted(t.members.items())},
                    "values": dict(sorted(t.values.items())),
                }
                for n, t in sorted(self.types.items())
            },
            "gvls": {
                g: {m: [v.type, v.init, v.kind] for m, v in sorted(ms.items())} for g, ms in sorted(self.gvls.items())
            },
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> StIndex:
        idx = cls()
        for n, t in data["types"].items():
            idx.types[n] = TypeDef(
                n,
                t["kind"],
                {m: Var(m, v[0], v[1], v[2]) for m, v in t["members"].items()},
                dict(t["values"]),
                t["base"],
            )
        for g, ms in data["gvls"].items():
            idx.gvls[g] = {m: Var(m, v[0], v[1], v[2]) for m, v in ms.items()}
        return idx


def base_type_name(type_text: str) -> str:
    t = type_text.strip()
    t = re.sub(r"^(?:REFERENCE|POINTER)\s+TO\s+", "", t, flags=re.I)
    if t.startswith("PL."):
        t = t[3:]
    return t


def array_info(type_text: str) -> tuple[str, str, str] | None:
    m = re.fullmatch(r"ARRAY\s*\[\s*(.+?)\s*\.\.\s*(.+?)\s*\]\s*OF\s+(.+)", type_text.strip(), re.I | re.S)
    return (m.group(1), m.group(2), m.group(3).strip()) if m else None


def strip_st_comments(text: str) -> str:
    text = re.sub(r"\(\*.*?\*\)", " ", text, flags=re.S)
    text = re.sub(r"\{[^}]*\}", " ", text)
    out = []
    for line in text.splitlines():
        res: list[str] = []
        quote = ""
        i = 0
        while i < len(line):
            c = line[i]
            if quote:
                res.append(c)
                if c == quote:
                    quote = ""
            elif c in "'\"":
                quote = c
                res.append(c)
            elif line.startswith("//", i):
                break
            else:
                res.append(c)
            i += 1
        out.append("".join(res))
    return "\n".join(out)


def split_top(text: str, sep: str) -> list[str]:
    """Деление по разделителю вне скобок и строк."""
    parts: list[str] = []
    depth = 0
    quote = ""
    cur: list[str] = []
    for c in text:
        if quote:
            cur.append(c)
            if c == quote:
                quote = ""
            continue
        if c in "'\"":
            quote = c
        elif c in "([":
            depth += 1
        elif c in ")]":
            depth -= 1
        if c == sep and depth == 0:
            parts.append("".join(cur))
            cur = []
        else:
            cur.append(c)
    parts.append("".join(cur))
    return parts


def parse_initializer(text: str) -> Any:
    """Значение инициализатора: (a := 1, b := (..)) → dict, [x, y] → list, скаляр → str."""
    t = text.strip()
    if t.startswith("(") and t.endswith(")") and ":=" in t:
        out: dict[str, Any] = {}
        for item in split_top(t[1:-1], ","):
            if ":=" not in item:
                continue
            k, v = item.split(":=", 1)
            out[k.strip()] = parse_initializer(v)
        return out
    if t.startswith("[") and t.endswith("]"):
        return [parse_initializer(x) for x in split_top(t[1:-1], ",") if x.strip()]
    return t


_HEADER_RE = re.compile(r"^(?P<kw>TYPE|FUNCTION_BLOCK|INTERFACE|FUNCTION|PROGRAM|METHOD|PROPERTY)\b(?P<rest>.*)$", re.I)
_SECTION_RE = re.compile(r"^(VAR_INPUT|VAR_OUTPUT|VAR_IN_OUT|VAR_GLOBAL|VAR_STAT|VAR_TEMP|VAR_INST|VAR)\b(.*)$", re.I)
_SECTION_KIND = {"VAR_INPUT": "input", "VAR_OUTPUT": "output", "VAR_IN_OUT": "inout"}


def parse_st(text: str, gvl_name: str = "") -> StIndex:
    """Разбор объявлений ST (DUT, GVL, ФБ, интерфейсы). Тела не разбираются."""
    idx = StIndex()
    cur_type: TypeDef | None = None
    section = ""
    section_mods = ""
    in_struct = False
    pending_enum = False
    pending_type = False  # после «TYPE X :» ждём STRUCT или «(» перечисления
    buf = ""
    for raw in strip_st_comments(text).splitlines():
        line = raw.strip()
        if not line:
            continue
        if pending_type:
            pending_type = False
            if line.startswith("("):
                pending_enum = True
        if not buf:
            hm = _HEADER_RE.match(line)
            if hm and not section and not in_struct:
                kw = hm.group("kw").upper()
                rest = hm.group("rest").strip()
                if kw == "TYPE":
                    m = re.match(r"(\w+)\s*:?\s*(.*)$", rest)
                    if m:
                        cur_type = TypeDef(m.group(1), "struct")
                        idx.types[cur_type.name] = cur_type
                        tail = m.group(2).strip()
                        pending_enum = tail.startswith("(")
                        pending_type = not tail
                        if pending_enum:
                            buf = tail
                            if ";" in buf:
                                _finish_enum(cur_type, buf)
                                buf = ""
                                pending_enum = False
                    continue
                if kw in ("FUNCTION_BLOCK", "INTERFACE", "FUNCTION", "PROGRAM"):
                    m = re.match(
                        r"(?:(?:ABSTRACT|FINAL|PUBLIC|INTERNAL)\s+)*(\w+)(?:\s*:\s*\w+)?(?:\s+EXTENDS\s+([\w.]+))?",
                        rest,
                        re.I,
                    )
                    if m:
                        kind = {"FUNCTION_BLOCK": "fb", "INTERFACE": "interface"}.get(kw, kw.lower())
                        cur_type = TypeDef(m.group(1), kind, base=m.group(2))
                        idx.types[cur_type.name] = cur_type
                    continue
                continue
            if pending_enum and cur_type is not None:
                buf = line
                if ";" in buf:
                    _finish_enum(cur_type, buf)
                    buf = ""
                    pending_enum = False
                continue
            up = line.upper()
            if up == "STRUCT":
                in_struct = True
                continue
            if up.startswith("END_STRUCT"):
                in_struct = False
                continue
            if up.startswith("END_TYPE"):
                cur_type = None
                continue
            if up.startswith("END_VAR"):
                section = ""
                continue
            if up.startswith(("END_FUNCTION_BLOCK", "END_INTERFACE", "END_FUNCTION", "END_PROGRAM")):
                cur_type = None
                continue
            sm = _SECTION_RE.match(line)
            if sm:
                section = sm.group(1).upper()
                section_mods = sm.group(2).upper()
                continue
        buf = (buf + " " + line).strip()
        if pending_enum and cur_type is not None:
            if ";" in buf:
                _finish_enum(cur_type, buf)
                buf = ""
                pending_enum = False
            continue
        parts = split_top(buf, ";")
        buf = parts.pop().strip()
        for decl in parts:
            var = _parse_decl(decl)
            if var is None:
                continue
            if in_struct and cur_type is not None:
                cur_type.members[var.name] = var
            elif section == "VAR_GLOBAL":
                var.kind = "const" if "CONSTANT" in section_mods else "var"
                idx.gvls.setdefault(gvl_name or "GVL", {})[var.name] = var
            elif section in _SECTION_KIND and cur_type is not None:
                var.kind = _SECTION_KIND[section]
                cur_type.members[var.name] = var
    return idx


def _finish_enum(t: TypeDef, text: str) -> None:
    t.kind = "enum"
    body = text[text.find("(") + 1 : text.rfind(")")]
    for item in split_top(body, ","):
        m = re.match(r"\s*(\w+)\s*(?::=\s*([-\w#]+))?", item)
        if m:
            val = m.group(2)
            t.values[m.group(1)] = int(val) if val and re.fullmatch(r"-?\d+", val) else None


def _parse_decl(decl: str) -> Var | None:
    d = decl.strip()
    if not d:
        return None
    m = re.match(r"(\w+(?:\s*,\s*\w+)*)\s*(?:AT\s+%\S+\s*)?:(?!=)\s*(.*)$", d, re.S)
    if not m:
        return None
    names = [n.strip() for n in m.group(1).split(",")]
    rest = m.group(2)
    parts = rest.split(":=", 1) if ":=" in rest else [rest]
    # := внутри скобок типа (STRING(...)) не встречается, поэтому достаточно первого вхождения
    type_text = re.sub(r"\s+", " ", parts[0]).strip()
    init = parts[1].strip() if len(parts) > 1 else None
    return Var(names[0], type_text, init)


# --------------------------------------------------------------------------------------------------
# Источники: перечень, тревоги, DESIGN, библиотека, генератор
# --------------------------------------------------------------------------------------------------


def read_semicolon_csv(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8", newline="") as f:
        lines = [line for line in f if not line.startswith("#")]
    return list(csv.DictReader(lines, delimiter=";"))


@dataclass
class Device:
    name: str
    dev_type: str
    dev_no: int
    desc: str
    tags: list[str] = field(default_factory=list)


class IoList:
    """Перечень сигналов `03_io_list.csv` (формат iolistgen)."""

    def __init__(self, path: Path) -> None:
        self.rows = read_semicolon_csv(path)
        self.by_tag = {r["tag"]: r for r in self.rows}
        self.tags = set(self.by_tag)
        self.devices: dict[str, Device] = {}
        for r in self.rows:
            dev = r["device"] or (r["tag"] if r["device_type"] else "")
            if not dev:
                continue
            if r["device_type"]:
                d = self.devices.setdefault(dev, Device(dev, "", 0, ""))
                d.dev_type = r["device_type"]
                d.dev_no = int(r["dev_no"])
                d.desc = r["dev_desc"] or r["description"]
            self.devices.setdefault(dev, Device(dev, "", 0, "")).tags.append(r["tag"])
        self.roles = {r["role"] for r in self.rows if r["role"]}

    def setpoints(self, tag: str) -> dict[str, float]:
        r = self.by_tag[tag]
        out = {}
        for key in ("HH", "H", "L", "LL"):
            v = doc_number(r["sp_" + key.lower()])
            if v is not None:
                out[key] = v
        return out

    def float_mark(self, tag: str) -> float | None:
        m = re.search(r"(\d+(?:,\d+)?) м\)", self.by_tag[tag]["description"])
        return doc_number(m.group(1)) if m else None

    def params(self, tag: str) -> dict[str, str]:
        out = {}
        for item in self.by_tag[tag]["params"].split(";"):
            if "=" in item:
                k, v = item.split("=", 1)
                out[k.strip()] = v.strip()
        return out


@dataclass
class Sources:
    """Все загруженные данные для проверок."""

    root: Path
    docs: dict[str, Doc]
    io: IoList
    io_md: Doc
    alarms: list[dict[str, str]]  # 05_alarm_list.csv
    gen_alarms: list[dict[str, str]]  # docs/alarms.csv (iolistgen)
    design: StIndex
    library: StIndex
    generator: StIndex
    svgs: dict[str, str]
    notes: list[str] = field(default_factory=list)

    @property
    def symbols(self) -> StIndex:
        idx = StIndex()
        idx.merge(self.library)
        idx.merge(self.generator)
        idx.merge(self.design)
        return idx


def design_index(doc: Doc) -> StIndex:
    """Объявления ST из блоков ```st документа DESIGN.md и перечисления из таблиц раздела 3."""
    idx = StIndex()
    for block in doc.blocks:
        if block.lang != "st":
            continue
        text = block.text
        gvl = ""
        for line in text.splitlines():
            s = line.strip()
            if not s:
                continue
            if not s.startswith("//"):
                break
            m = re.search(r"\b(GVL_\w+)\b", s)
            if m:
                gvl = m.group(1)
                break
        if not gvl:
            h = doc.heading_at(block.line)
            m = re.search(r"\b(GVL_\w+)\b", h.title) if h else None
            gvl = m.group(1) if m else ""
        bare = strip_st_comments(text)
        if not re.search(r"^\s*(TYPE|VAR_GLOBAL|FUNCTION_BLOCK|INTERFACE|FUNCTION|PROGRAM)\b", bare, re.M) and gvl:
            text = "VAR_GLOBAL\n" + text + "\nEND_VAR\n"
        part = parse_st(text, gvl)
        fb = next((t for t in part.types.values() if t.kind in ("fb", "interface")), None)
        if fb is not None:
            for line in block.text.splitlines():
                for mm in re.finditer(r"(?://\s*|;\s*)(?:(METHOD|PROPERTY)\s+)?([A-Z]\w*)\s*(\(|:)", line):
                    if line.strip().startswith("//") and mm.group(2) not in fb.members:
                        kind = "property" if mm.group(1) == "PROPERTY" or mm.group(3) == ":" else "method"
                        fb.members[mm.group(2)] = Var(mm.group(2), kind.upper(), None, kind)
        idx.merge(part)
    for table in doc.tables():
        for _no, cells in table.rows:
            if len(cells) < 2:
                continue
            m = re.match(r"`(E_\w+)`", cells[0])
            if not m:
                continue
            pairs = re.findall(r"`(\w+) := (-?\d+)`", cells[1])
            if pairs:
                t = idx.types.setdefault(m.group(1), TypeDef(m.group(1), "enum"))
                t.kind = "enum"
                for k, v in pairs:
                    t.values[k] = int(v)
    return idx


def design_constants(design: StIndex) -> dict[str, Var]:
    return design.gvls.get("GVL_Const", {})


def library_index_from_repo(repo: Path) -> StIndex:
    """Символы plc-process-lib из исходников: DUT, GVL, ФБ, функции, интерфейсы (с свойствами и методами)."""
    idx = StIndex()
    src = repo / "src"
    for f in sorted((src / "DUTs").rglob("*.dut.st")):
        idx.merge(parse_st(f.read_text(encoding="utf-8")))
    for f in sorted((src / "GVLs").glob("*.gvl.st")):
        gvl = f.name.split(".")[0]
        idx.merge(parse_st(f.read_text(encoding="utf-8"), gvl))
    objects = sorted((src / "POUs").rglob("*.decl.st")) + sorted((src / "Interfaces").rglob("*.itf.st"))
    for f in objects:
        stem = f.name.split(".")[0]
        if stem != f.parent.name or stem == "PRG_Main":  # PRG_Main — пример шаблона в библиотеке
            continue
        part = parse_st(f.read_text(encoding="utf-8"))
        idx.merge(part)
        t = part.types.get(stem)
        if t is None:
            continue
        for p in sorted(f.parent.glob("*.prop.decl.st")):
            m = re.match(
                r"\s*PROPERTY\s+(?:(PUBLIC|PROTECTED|PRIVATE|INTERNAL)\s+)?(\w+)\s*:\s*([\w.]+)",
                strip_st_comments(p.read_text(encoding="utf-8")),
                re.I,
            )
            if m and (m.group(1) or "PUBLIC").upper() == "PUBLIC":
                idx.types[stem].members[m.group(2)] = Var(m.group(2), m.group(3), None, "property")
        for p in sorted(f.parent.glob("*.method.decl.st")):
            m = re.match(
                r"\s*METHOD\s+(?:(PUBLIC|PROTECTED|PRIVATE|INTERNAL|ABSTRACT|FINAL)\s+)*(\w+)\s*(?::\s*([\w.]+))?",
                strip_st_comments(p.read_text(encoding="utf-8")),
                re.I,
            )
            text = p.read_text(encoding="utf-8")
            if m and not re.search(r"METHOD\s+(?:\w+\s+)*?(PROTECTED|PRIVATE|INTERNAL)\b", text, re.I):
                idx.types[stem].members[m.group(2)] = Var(m.group(2), m.group(3) or "METHOD", None, "method")
    return idx


def find_repo(env: str, name: str, root: Path, marker: str) -> Path | None:
    """Репозиторий из переменной ``env``; без неё — соседний каталог ``name``, у рабочей копии ``git worktree``
    в ``<портфолио>/_wt/`` — на уровень выше (как ``generate.find_iolistgen``)."""
    raw = os.environ.get(env)
    candidates = [Path(raw)] if raw else [root.parent / name, root.parent.parent / name]
    for c in candidates:
        if (c / marker).exists():
            return c
    return None


def library_index(root: Path, notes: list[str]) -> StIndex:
    snapshot = LIB_SNAPSHOT
    if snapshot.exists():
        return StIndex.from_json(json.loads(snapshot.read_text(encoding="utf-8")))
    repo = find_repo("PL_REPO", "plc-process-lib", root, "src/POUs/Devices/FB_MotorVfd")
    if repo is None:
        notes.append("нет снимка plc-process-lib и исходников библиотеки: члены типов PL не проверяются")
        return StIndex()
    return library_index_from_repo(repo)


def derive_generator_index(io: IoList, io_md: Doc) -> StIndex:
    """Имена, которые генерирует iolistgen по перечню (без запуска генератора), — правила GENERATORS.md."""
    idx = StIndex()
    gio: dict[str, Var] = {}
    for _no, line in io_md.prose():
        for name in re.findall(r"`GVL_IO\.(\w+)`", line):
            typ = next((t for p, t in PREFIX_TYPE if name.startswith(p) and name[len(p) : len(p) + 1].isupper()), "")
            gio[name] = Var(name, typ or "BOOL")
    for r in io.rows:
        if r["mb_link"] and r["mb_slave"]:
            name = "xMbOk_{}_S{}".format(r["mb_link"].replace("-", "_"), r["mb_slave"])
            gio[name] = Var(name, "BOOL")
    for dev in io.devices.values():
        if dev.dev_type == "MotorVfd":
            for pattern, typ in ADAPTER_VARS:
                name = pattern.format(d=dev.name)
                gio[name] = Var(name, typ)
    idx.gvls["GVL_IO"] = gio
    devs = sorted(io.devices.values(), key=lambda d: d.dev_no)
    idx.gvls["GVL_Devices"] = {f"fb{d.name}": Var(f"fb{d.name}", f"PL.FB_{d.dev_type}") for d in devs}
    hmi = {f"st{d.name}Cmd": Var(f"st{d.name}Cmd", f"PL.ST_{TYPE_SHORT[d.dev_type]}Cmd") for d in devs}
    hmi["xApplyProjectCfg"] = Var("xApplyProjectCfg", "BOOL")
    idx.gvls["GVL_Hmi"] = hmi
    persist = {"uiLayoutVersion": Var("uiLayoutVersion", "UINT")}
    for d in devs:
        persist[f"st{d.name}Cfg"] = Var(f"st{d.name}Cfg", f"PL.ST_{TYPE_SHORT[d.dev_type]}Cfg")
        if d.dev_type not in ("AnalogInput", "DigitalInput"):
            persist[f"st{d.name}Retain"] = Var(f"st{d.name}Retain", "PL.ST_DeviceRetain")
    # блок станции (DESIGN, раздел 4.7) — данные приложения persist_extra после устройств
    for line in PERSIST_EXTRA.read_text(encoding="utf-8").splitlines():
        m = re.match(r"^\s*([A-Za-z_]\w*)\s*:\s*([A-Za-z_][\w.]*)", line)
        if m and not line.lstrip().startswith("//"):
            persist[m.group(1)] = Var(m.group(1), m.group(2))
    idx.gvls["GVL_Persist"] = persist
    idx.gvls["GVL_CfgProject"] = {
        f"st{d.name}Cfg": Var(f"st{d.name}Cfg", f"PL.ST_{TYPE_SHORT[d.dev_type]}Cfg", None, "const") for d in devs
    }
    idx.gvls["GVL_DevIdx"] = {d.name: Var(d.name, "UINT", str(d.dev_no), "const") for d in devs}
    return idx


def generated_gvl_index(gvl_dir: Path) -> StIndex:
    """Имена из сгенерированных файлов `src/GVLs/Generated` (настоящий вывод iolistgen)."""
    idx = StIndex()
    for f in sorted(gvl_dir.glob("*.st")):
        gvl = f.name.split(".")[0]
        idx.merge(parse_st(f.read_text(encoding="utf-8"), gvl))
    return idx


# Настройки генератора проекта (DESIGN, раздел 4.6): iolistgen.toml корня репозитория и опции, которые
# tools_project/generate.py передаёт через --set (тексты тревог «смысл слота», как в 05)
IOLISTGEN_SETS = generate.IOLISTGEN_SETS


def run_iolistgen(repo: Path, io_csv: Path, out: Path, sets: Sequence[str] = IOLISTGEN_SETS) -> None:
    """Перегенерация перечня во временный каталог (сверка снимков с настоящим генератором)."""
    root = io_csv.resolve().parent.parent
    cmd = [sys.executable, "-m", "iolistgen", "generate", str(io_csv), "--out", str(out)]
    cmd += ["--config", str(root / "iolistgen.toml")]
    for item in sets:
        cmd += ["--set", item]
    env = dict(os.environ)
    env["PYTHONPATH"] = os.pathsep.join(p for p in (str(repo), env.get("PYTHONPATH", "")) if p)
    subprocess.run(cmd, cwd=root, env=env, check=True, capture_output=True)


def load_sources(root: Path = REPO_ROOT) -> Sources:
    docs_dir = root / "docs"
    notes: list[str] = []
    docs = {name: Doc.load(docs_dir / name) for name in MD_DOCS if (docs_dir / name).exists()}
    if (root / "README.md").exists():
        docs["README.md"] = Doc.load(root / "README.md")
    io = IoList(docs_dir / "03_io_list.csv")
    io_md = Doc.load(docs_dir / "03_io_list.md")
    design = design_index(docs["DESIGN.md"]) if "DESIGN.md" in docs else StIndex()
    library = library_index(root, notes)
    gen_dir = root / "src" / "GVLs" / "Generated"
    generator = generated_gvl_index(gen_dir) if gen_dir.is_dir() else derive_generator_index(io, io_md)
    svgs = {p.name: p.read_text(encoding="utf-8") for p in sorted((docs_dir / "hmi").glob("*.svg"))}
    return Sources(
        root=root,
        docs=docs,
        io=io,
        io_md=io_md,
        alarms=read_semicolon_csv(docs_dir / "05_alarm_list.csv"),
        gen_alarms=read_semicolon_csv(docs_dir / "alarms.csv"),
        design=design,
        library=library,
        generator=generator,
        svgs=svgs,
        notes=notes,
    )


# --------------------------------------------------------------------------------------------------
# Шаблоны «по каждому насосу»: P10n, IT1n1, KNS1.ULn, xMbOk_RS485_1_Sn, {lead}
# --------------------------------------------------------------------------------------------------

_TEMPLATE_RES = (
    re.compile(r"(?<=P10)n"),
    re.compile(r"(?<=[A-Z]{2}1)n(?=\d)"),
    re.compile(r"(?<=_S)n\b"),
    re.compile(r"(?<=UL)n\b"),
    re.compile(r"\{lead\}"),
)


def expand_pumps(text: str) -> list[str]:
    """Подстановка номера насоса 1…3 в шаблонные имена; без шаблона — сам текст."""
    if not any(r.search(text) for r in _TEMPLATE_RES):
        return [text]
    out = []
    for n in ("1", "2", "3"):
        t = text
        for r in _TEMPLATE_RES:
            t = r.sub(n, t)
        out.append(t)
    return out


# --------------------------------------------------------------------------------------------------
# Пути переменных
# --------------------------------------------------------------------------------------------------

_PATH_RE = re.compile(r"(?<![\w.>])([A-Za-z_]\w*(?:\{lead\}\w*)?(?:(?:\.\w+(?:\{lead\}\w*)?)|(?:\[[^\]\n]*\]))+)")


def split_path(path: str) -> list[tuple[str, list[str]]]:
    segs = []
    for part in split_top(path, "."):
        m = re.fullmatch(r"(\w+)((?:\[[^\]]*\])*)", part)
        if not m:
            return []
        segs.append((m.group(1), re.findall(r"\[([^\]]*)\]", m.group(2))))
    return segs


def resolve_bound(text: str, consts: dict[str, Var]) -> int | None:
    t = text.strip()
    if re.fullmatch(r"-?\d+", t):
        return int(t)
    m = re.fullmatch(r"(?:GVL_Const\.)?(\w+)\s*(?:([-+])\s*(\d+))?", t)
    if m and m.group(1) in consts and consts[m.group(1)].init:
        base = st_scalar(consts[m.group(1)].init or "")
        if isinstance(base, float):
            val = int(base)
            if m.group(2):
                val = val + int(m.group(3)) if m.group(2) == "+" else val - int(m.group(3))
            return val
    return None


@dataclass
class Resolution:
    ok: bool
    verified: bool  # True — путь проверен до конца
    type: str
    message: str = ""


def resolve_path(path: str, idx: StIndex, consts: dict[str, Var]) -> Resolution:
    segs = split_path(path)
    if not segs:
        return Resolution(True, False, "")
    root, root_idx = segs[0]
    if root not in idx.gvls:
        return Resolution(False, True, "", f"нет глобального списка {root}")
    if root_idx:
        return Resolution(False, True, "", f"{root} — не массив")
    members: dict[str, Var] | None = idx.gvls[root]
    typ = ""
    walked = root
    for i, (name, indexes) in enumerate(segs[1:], 1):
        if members is None:
            return Resolution(True, False, typ)
        if not members:
            if re.fullmatch(r"\d+", name) and i == len(segs) - 1:
                return Resolution(True, True, "BOOL")  # бит слова
            return Resolution(False, True, typ, f"{walked} ({typ}) не имеет полей, а путь продолжается: .{name}")
        if name not in members:
            return Resolution(False, True, typ, f"в {walked} ({typ or root}) нет {name}")
        typ = members[name].type
        walked += "." + name
        for index in indexes:
            arr = array_info(typ)
            if arr is None:
                return Resolution(False, True, typ, f"{walked} ({typ}) — не массив")
            lo, hi = resolve_bound(arr[0], consts), resolve_bound(arr[1], consts)
            for val in re.findall(r"^\s*(\d+)\s*(?:\.\.\s*(\d+))?\s*$", index):
                for v in (x for x in val if x):
                    if lo is not None and hi is not None and not lo <= int(v) <= hi:
                        return Resolution(False, True, typ, f"индекс {v} вне [{lo}..{hi}] у {walked}")
            typ = arr[2]
            walked += f"[{index}]"
        if array_info(typ) is not None and i < len(segs) - 1:
            return Resolution(False, True, typ, f"{walked} — массив, нужен индекс")
        members = idx.members_of(typ)
    known = members is not None or array_info(typ) is not None or typ in ("METHOD", "PROPERTY")
    return Resolution(True, known or not segs[1:], typ)


def doc_aliases(doc: Doc) -> dict[str, str]:
    """Сокращения, которые документ определяет сам.

    «`Sts` — `GVL_Station.stStationSts`», «`Inj` = `GVL_Sim.stFaultInj`».
    """
    out: dict[str, str] = {}
    text = re.sub(r"\s*\n\s*", " ", "\n".join(line for _no, line in doc.prose()))
    for m in re.finditer(r"`(\w+)((?:\.\w+)*)`\s*(?:—|=)\s*`(GVL_\w+(?:\.\w+)*)`", text):
        short, suffix, target = m.group(1), m.group(2), m.group(3)
        if suffix:
            # «`Hmi.stP101Cmd` — `GVL_Hmi.stP101Cmd`»: сокращение — часть до общего хвоста
            if not target.endswith(suffix):
                continue
            target = target[: -len(suffix)]
        if short != target.split(".")[-1]:
            out[short] = target
    return out


def global_aliases(idx: StIndex) -> dict[str, str]:
    """Имя переменной, которое есть ровно в одном глобальном списке, можно писать без списка."""
    seen: dict[str, list[str]] = {}
    for gvl, members in idx.gvls.items():
        if gvl == "GVL_DevIdx":  # константы с именами устройств совпадают с позициями (LT101.FAIL — код тревоги)
            continue
        for name in members:
            seen.setdefault(name, []).append(gvl)
    return {name: f"{gvls[0]}.{name}" for name, gvls in seen.items() if len(gvls) == 1}


def iter_doc_paths(doc: Doc, roots: set[str]) -> Iterator[tuple[int, str, str]]:
    """(строка, путь, текст после пути) из фрагментов `...` и блоков ```st/```toml."""
    sources: list[tuple[int, str]] = [(no, span) for no, span, _ in doc.spans()]
    for block in doc.blocks:
        if block.lang in ("st", "toml", "text", ""):
            for k, line in enumerate(block.text.splitlines()):
                sources.append((block.line + k, line))
    for no, text in sources:
        for m in _PATH_RE.finditer(text):
            path = m.group(1)
            root = re.match(r"\w+(?:\{lead\}\w*)?", path)
            if root is None:
                continue
            root_name = expand_pumps(root.group(0))[0]
            if root_name not in roots:
                continue
            after = text[m.end() :]
            if re.search(r"\.(?:gvl|pvl|dut|st|j2|py|md|csv|json|toml)\b", path):
                continue  # имя файла, а не путь переменной
            if after.startswith(("<", "*")):
                # шаблон имени (`GVL_Persist.st<TAG>Cfg`): последнюю часть не проверяем
                path = path.rsplit(".", 1)[0] if "." in path else ""
                if not path:
                    continue
            elif after.startswith("("):
                path = path.rsplit(".", 1)[0] if "." in path else ""
                if "." not in path:
                    continue
            yield no, path, after


# --------------------------------------------------------------------------------------------------
# Проверки
# --------------------------------------------------------------------------------------------------

CheckFn = Callable[[Sources], list[Finding]]
CHECKS: dict[str, tuple[str, CheckFn]] = {}


def check(code: str, title: str) -> Callable[[CheckFn], CheckFn]:
    def deco(fn: CheckFn) -> CheckFn:
        CHECKS[code] = (title, fn)
        return fn

    return deco


def all_texts(src: Sources, svg: bool = False) -> Iterator[tuple[str, int, str]]:
    """(документ, строка, текст строки) по всем сверяемым документам, 05 и (по желанию) SVG."""
    for name, doc in src.docs.items():
        for no, line in enumerate(doc.lines, 1):
            yield name, no, line
    alarm_path = src.root / "docs" / "05_alarm_list.csv"
    for no, line in enumerate(alarm_path.read_text(encoding="utf-8").splitlines(), 1):
        yield "05_alarm_list.csv", no, line
    if svg:
        for name, text in src.svgs.items():
            for no, line in enumerate(text.splitlines(), 1):
                yield f"hmi/{name}", no, line


_TAG_RE = re.compile(
    r"(?<![\w.#/-])((?:[A-Z]{2,3}\d{3}|P\d{3}|[A-Z]{2}1n\d|P10n|V\d|HA\d|HL\d|K\d)(?:_[A-Z]{2,5})?)(?![\w])"
)


@check("C01", "позиции (теги) в документах есть в перечне сигналов")
def check_tags(src: Sources) -> list[Finding]:
    known = src.io.tags | set(src.io.devices) | EXTRA_TAGS
    out = []
    for name, no, line in all_texts(src, svg=True):
        if name == "ASSUMPTIONS.md":
            continue
        clean = re.sub(r"https?://\S+", "", line)
        for m in _TAG_RE.finditer(clean):
            token = m.group(1)
            if token in NOT_TAGS or re.fullmatch(NOT_TAG_PATTERN, token):
                continue
            for t in expand_pumps(token):
                if t not in known:
                    out.append(Finding("C01", name, no, f"позиции {t} нет в 03_io_list.csv"))
    return out


_ALARM_CODE_RE = re.compile(
    r"(?<![\w.])((?:[A-Z]{1,4}\d{1,3}|[A-Z]{2}1n\d|P10n|P10\{lead\}|KNS1|LIC101|V1))\.([A-Z][A-Z0-9]{0,6}n?)(?![\w(<])(?!\.[\d<])"
)


def alarm_codes(src: Sources) -> dict[str, dict[str, str]]:
    return {r["code"]: r for r in src.alarms}


def event_codes(src: Sources) -> set[int]:
    return set(events_04(src).keys())


@check("C02", "коды тревог в документах есть в 05_alarm_list.csv; номер и приоритет рядом с кодом совпадают")
def check_alarm_codes(src: Sources) -> list[Finding]:
    codes = alarm_codes(src)
    events = event_codes(src)
    out = []
    for name, no, line in all_texts(src, svg=True):
        if name in ("05_alarm_list.csv", "ASSUMPTIONS.md"):
            continue
        for m in _ALARM_CODE_RE.finditer(line):
            dev, suf = m.group(1), m.group(2)
            if dev in ("KNS1",) and re.fullmatch(r"E\d+", suf):
                if 101000 + int(suf[1:]) not in events:
                    out.append(
                        Finding(
                            "C02", name, no, f"событие {dev}.{suf}: нет номера {101000 + int(suf[1:])} в 04, раздел 16"
                        )
                    )
                continue
            for code in expand_pumps(f"{dev}.{suf}"):
                if code not in codes:
                    out.append(Finding("C02", name, no, f"тревоги {code} нет в 05_alarm_list.csv"))
        # «`P101.FTS` (110, Medium)» и «`A`, `B` (1, 2)»
        for m in re.finditer(
            r"((?:`[^`]+`(?:,\s*|\s+и\s+))*`[^`]+`)\s*\(([\d, ]+?)(?:,\s*(None|Low|Medium|High|Critical))?\)", line
        ):
            names = re.findall(r"`([^`]+)`", m.group(1))
            ids = [int(x) for x in re.findall(r"\d+", m.group(2))]
            prio = m.group(3)
            pairs: list[tuple[str, int]] = []
            if len(ids) == 1 and names[-1] in codes:
                pairs = [(names[-1], ids[0])]
            elif len(ids) == len(names) and all(n in codes for n in names):
                pairs = list(zip(names, ids, strict=True))
            for code, num in pairs:
                row = codes[code]
                if int(row["id"]) != num:
                    out.append(Finding("C02", name, no, f"{code}: номер {num}, в 05 — {row['id']}"))
                if prio and len(pairs) == 1 and row["priority"] != prio:
                    out.append(Finding("C02", name, no, f"{code}: приоритет {prio}, в 05 — {row['priority']}"))
    return out


@check("C03", "тревоги устройств в 05 совпадают со списком генератора iolistgen (docs/alarms.csv)")
def check_alarms_vs_generator(src: Sources) -> list[Finding]:
    out = []
    sha = re.search(r"SHA-256 перечня ([0-9a-f]{12})", (src.root / "docs" / "alarms.csv").read_text(encoding="utf-8"))
    if sha:
        for name, no, line in all_texts(src):
            for m in re.finditer(r"SHA-256[^0-9a-f|]{0,24}([0-9a-f]{12})\b", line):
                if m.group(1) != sha.group(1):
                    out.append(
                        Finding("C03", name, no, f"SHA-256 перечня {m.group(1)}, в docs/alarms.csv — {sha.group(1)}")
                    )
        md = re.search(r"SHA-256 перечня ([0-9a-f]{12})", src.io_md.text)
        if md and md.group(1) != sha.group(1):
            out.append(
                Finding(
                    "C03",
                    "03_io_list.md",
                    0,
                    f"SHA-256 {md.group(1)} ≠ docs/alarms.csv {sha.group(1)}: перегенерировать",
                )
            )
    gen = {r["code"]: r for r in src.gen_alarms}
    dev_rows = {r["code"]: r for r in src.alarms if r["source"] == "device"}
    for code in sorted(set(gen) - set(dev_rows)):
        out.append(Finding("C03", "05_alarm_list.csv", 0, f"нет тревоги устройства {code} из docs/alarms.csv"))
    for code in sorted(set(dev_rows) - set(gen)):
        out.append(Finding("C03", "05_alarm_list.csv", 0, f"тревоги {code} нет в docs/alarms.csv генератора"))
    for code in sorted(set(gen) & set(dev_rows)):
        g, r = gen[code], dev_rows[code]
        for col in ("id", "tag", "slot", "priority", "text_ru", "delay_s"):
            if g[col].strip() != r[col].strip():
                out.append(Finding("C03", "05_alarm_list.csv", 0, f"{code}.{col}: «{r[col]}», генератор — «{g[col]}»"))
        if g["setpoint"].strip():
            a, b = doc_number(g["setpoint"]), doc_number(r["setpoint"])
            if a is None or b is None or not same_value(a, b):
                out.append(
                    Finding(
                        "C03", "05_alarm_list.csv", 0, f"{code}.setpoint: {r['setpoint']}, генератор — {g['setpoint']}"
                    )
                )
    return out


def station_alarm_cfg(src: Sources) -> list[dict[str, Any]]:
    """`ST_StationCfg.astAlarm` из DESIGN (инициализатор массива)."""
    t = src.design.types.get("ST_StationCfg")
    if t is None or "astAlarm" not in t.members or not t.members["astAlarm"].init:
        return []
    value = parse_initializer(t.members["astAlarm"].init or "")
    return [v if isinstance(v, dict) else {} for v in value] if isinstance(value, list) else []


@check("C04", "перечень тревог 05: номера, коды, слоты, приоритеты; станция — по 04 §15 и DESIGN")
def check_alarm_list(src: Sources) -> list[Finding]:
    out = []
    doc = "05_alarm_list.csv"
    raw = [
        (no, line)
        for no, line in enumerate((src.root / "docs" / doc).read_text(encoding="utf-8").splitlines(), 1)
        if line and not line.startswith("#")
    ]
    width = len(raw[0][1].split(";")) if raw else 0
    for no, line in raw:
        if len(line.split(";")) != width:
            out.append(
                Finding(
                    "C04", doc, no, f"{len(line.split(';'))} полей, в заголовке {width} (точка с запятой в тексте?)"
                )
            )
    seen: set[str] = set()
    pmi = pmi_ids(src)
    consts = design_constants(src.design)
    for r in src.alarms:
        code = r["code"]
        if r["id"] in seen:
            out.append(Finding("C04", doc, 0, f"номер {r['id']} повторяется"))
        seen.add(r["id"])
        if not code.startswith(r["tag"] + "."):
            out.append(Finding("C04", doc, 0, f"{code}: код не начинается с тега {r['tag']}"))
        if r["priority"] not in ALARM_PRIORITIES:
            out.append(Finding("C04", doc, 0, f"{code}: приоритет {r['priority']} вне E_AlarmPriority"))
        slot = int(r["slot"])
        if r["source"] == "device":
            dev = src.io.devices.get(r["tag"])
            if dev is None:
                out.append(Finding("C04", doc, 0, f"{code}: устройства {r['tag']} нет в перечне"))
            elif int(r["id"]) != dev.dev_no * 10 + slot:
                out.append(Finding("C04", doc, 0, f"{code}: номер {r['id']} ≠ dev_no · 10 + слот"))
        elif r["tag"] == "KNS1" and int(r["id"]) != 100000 + slot:
            out.append(Finding("C04", doc, 0, f"{code}: номер {r['id']} ≠ 100000 + slot"))
        elif r["tag"] == "LIC101":
            base = resolve_bound("LIC101_ALARM_ID_BASE", consts)
            if base is not None and int(r["id"]) != base + slot:
                out.append(Finding("C04", doc, 0, f"{code}: номер {r['id']} ≠ LIC101_ALARM_ID_BASE + слот"))
        for ref in re.findall(r"PMI-\d{2}", r["pmi"]):
            if ref not in pmi:
                out.append(Finding("C04", doc, 0, f"{code}: проверки {ref} нет в 06_PMI.md"))
    station = sorted((r for r in src.alarms if r["tag"] == "KNS1"), key=lambda r: int(r["slot"]))
    count = resolve_bound("STN_ALARM_COUNT", consts)
    if count is not None and count != len(station):
        out.append(Finding("C04", "DESIGN.md", 0, f"STN_ALARM_COUNT = {count}, тревог станции в 05 — {len(station)}"))
    enum = src.design.types.get("E_StationAlarm")
    cfg = station_alarm_cfg(src)
    for r in station:
        slot = int(r["slot"])
        suffix = r["code"].split(".", 1)[1]
        if enum is not None and enum.values.get(suffix) != slot:
            out.append(Finding("C04", "DESIGN.md", 0, f"E_StationAlarm.{suffix} ≠ slot {slot} из 05"))
        if cfg and slot <= len(cfg):
            item = cfg[slot - 1]
            prio = str(st_scalar(str(item.get("ePriority", "Medium"))))
            if prio != r["priority"]:
                out.append(
                    Finding(
                        "C04",
                        "DESIGN.md",
                        0,
                        f"ST_StationCfg.astAlarm[{slot}] ({suffix}): {prio}, в 05 — {r['priority']}",
                    )
                )
            delay = st_scalar(str(item.get("tOnDelay", "T#0S")))
            logic = station_cfg_defaults(src).get(STATION_LOGIC_DELAY.get(suffix.rstrip("123"), ""), 0.0)
            if isinstance(delay, float) and isinstance(logic, float):
                delay += logic
            if not same_value(delay, float(r["delay_s"] or 0)):
                out.append(
                    Finding(
                        "C04",
                        "DESIGN.md",
                        0,
                        f"ST_StationCfg.astAlarm[{slot}] ({suffix}): задержка {delay} с, в 05 — {r['delay_s']}",
                    )
                )
    if "04_algorithms.md" in src.docs:
        doc04 = src.docs["04_algorithms.md"]
        rows = {}
        for t in doc04.section_tables("15"):
            if t.header[:2] == ["Slot", "Код"]:
                for no, cells in t.rows:
                    codes = re.findall(r"`?(KNS1\.\w+|UL\d|UL3)`?", cells[1])
                    slots = re.findall(r"\d+", cells[0])
                    if len(slots) == 2:
                        first, last = int(slots[0]), int(slots[1])
                        stem = re.match(r"`?KNS1\.([A-Z]+)\d", cells[1])
                        for s in range(first, last + 1):
                            rows[s] = (no, f"KNS1.{stem.group(1) if stem else ''}{s - first + 1}", cells[2])
                    elif slots and codes:
                        rows[int(slots[0])] = (no, codes[0], cells[2])
        for r in station:
            slot = int(r["slot"])
            if slot not in rows:
                out.append(
                    Finding("C04", "04_algorithms.md", 0, f"нет строки slot {slot} ({r['code']}) в таблице раздела 15")
                )
                continue
            no, code, prio = rows[slot]
            if code != r["code"]:
                out.append(Finding("C04", "04_algorithms.md", no, f"slot {slot}: {code}, в 05 — {r['code']}"))
            if prio.strip("` ") != r["priority"]:
                out.append(
                    Finding("C04", "04_algorithms.md", no, f"{r['code']}: приоритет {prio}, в 05 — {r['priority']}")
                )
    return out


def station_cfg_defaults(src: Sources) -> dict[str, float | bool | str]:
    t = src.design.types.get("ST_StationCfg")
    if t is None:
        return {}
    return {n: st_scalar(v.init) for n, v in t.members.items() if v.init and not v.init.strip().startswith(("[", "("))}


def lic101_cfg(src: Sources) -> dict[str, float | bool | str]:
    var = src.design.gvls.get("GVL_Persist", {}).get("stLIC101Cfg")
    if var is None or not var.init:
        return {}
    value = parse_initializer(var.init)
    if not isinstance(value, dict):
        return {}
    out: dict[str, float | bool | str] = {k: st_scalar(v) for k, v in value.items() if isinstance(v, str)}
    alarms = value.get("astAlarm")
    if isinstance(alarms, list) and alarms and isinstance(alarms[0], dict):
        out["astAlarm[0].ePriority"] = st_scalar(str(alarms[0].get("ePriority", "")))
    return out


def device_cfg_expectations(src: Sources) -> dict[str, list[float | bool | str]]:
    """Допустимые значения параметров устройств: перечень (params, задержки) и умолчания библиотеки."""
    exp: dict[str, list[float | bool | str]] = {}

    def add(name: str, value: float | bool | str) -> None:
        exp.setdefault(name, []).append(value)

    for r in src.io.rows:
        for key, val in src.io.params(r["tag"]).items():
            add(key.split(".")[-1], st_scalar(val))
        if r["role"] == "CMD_RUN":
            if r["delay_on_s"]:
                add("tFbStart", float(r["delay_on_s"]))
            if r["delay_off_s"]:
                add("tFbStop", float(r["delay_off_s"]))
    for tname in ("ST_MotorCfg", "ST_VfdCfg", "ST_AnalogInputCfg", "ST_DigitalInputCfg", "ST_AlarmCfg", "ST_PidCfg"):
        t = src.library.types.get(tname)
        if t is None:
            continue
        for m, v in t.members.items():
            if v.init and not v.init.strip().startswith(("[", "(")):
                add(m, st_scalar(v.init))
    for item in station_alarm_cfg(src):
        for k, v in item.items():
            if isinstance(v, str):
                add(k, st_scalar(v))
    return exp


_INLINE_RE = re.compile(
    r"`(?P<name>[a-z]{1,3}[A-Z]\w*)`\s*(?:\(\s*|=\s*|—\s*)(?P<val>T#\w+|[-−]?\d+(?:,\d+)?)\s*(?P<unit>мин|мс|ч|с|м(?![\w³²])|%|А)?"
)
_INLINE_TEXT_RE = re.compile(
    r"(?<![\w.`])(?P<name>[a-z]{1,3}[A-Z]\w*)\s*(?:\(\s*|=\s*)(?P<val>[-−]?\d+(?:,\d+)?)\s*(?P<unit>мин|мс|ч|с|м(?![\w³²])|%|А)"
)


def _inline_value(name: str, val: str, unit: str | None) -> float | None:
    t = parse_time(val)
    if t is not None:
        return t
    num = doc_number(val)
    if num is None:
        return None
    if name.startswith("t"):
        if not unit or unit not in DOC_UNIT_S:
            return None
        return num * DOC_UNIT_S[unit]
    return num


@check("C05", "значения параметров в тексте (`tAssistOn` (30 с)) совпадают с уставками DESIGN и перечня")
def check_inline_params(src: Sources) -> list[Finding]:
    station = station_cfg_defaults(src)
    pid = lic101_cfg(src)
    devices = device_cfg_expectations(src)
    out = []
    for name, doc in src.docs.items():
        if name == "ASSUMPTIONS.md":
            continue
        texts: list[tuple[int, str, re.Pattern[str]]] = [(no, line, _INLINE_RE) for no, line in doc.prose()]
        for block in doc.blocks:
            if block.lang == "text":
                texts += [(block.line + k, line, _INLINE_TEXT_RE) for k, line in enumerate(block.text.splitlines())]
        for no, line, rx in texts:
            for m in rx.finditer(line):
                pname = m.group("name")
                value = _inline_value(pname, m.group("val"), m.group("unit"))
                if value is None:
                    continue
                if pname in station:
                    expected: list[float | bool | str] = [station[pname]]
                elif pname in pid:
                    expected = [pid[pname]]
                elif pname in devices:
                    expected = devices[pname]
                else:
                    continue
                if not any(same_value(value, e) for e in expected):
                    shown = ", ".join(str(e) for e in expected)
                    out.append(
                        Finding(
                            "C05", name, no, f"{pname} = {m.group('val')} {m.group('unit') or ''}: ожидается {shown}"
                        )
                    )
    return out


@check("C06", "уставки 04 (разделы 1, 18.1, 18.2) совпадают с перечнем сигналов, 05 и DESIGN")
def check_setpoints_04(src: Sources) -> list[Finding]:
    out: list[Finding] = []
    if "04_algorithms.md" not in src.docs:
        return out
    doc = src.docs["04_algorithms.md"]
    io = src.io
    station = station_cfg_defaults(src)
    pid = lic101_cfg(src)
    retain = src.design.types.get("ST_StationRetain")
    lt = io.setpoints("LT101")
    marks = {"LS102": io.float_mark("LS102"), "LS103": io.float_mark("LS103")}
    # Раздел 1: отметки уровня
    for t in doc.section_tables("1"):
        for no, cells in t.rows:
            mark = doc_number(cells[0])
            if mark is None:
                continue
            what = cells[1]
            expected: list[float] = []
            for pname in cell_names(what):
                sval = station.get(pname)
                if isinstance(sval, float):
                    expected.append(sval)
            for key in ("HH", "H", "L", "LL"):
                if re.match(rf"{key}\b", what):
                    expected.append(lt[key])
            for tag, val in marks.items():
                if (
                    tag in what
                    and val is not None
                    and "поплавок" in what
                    and "не сработал" not in what
                    and "ложно" not in what
                ):
                    expected.append(val)
            if "верх шкалы" in what:
                expected.append(float(io.by_tag["LT101"]["range_max"]))
            if "перелив" in what:
                model = sim_cfg_defaults(src).get("rLevelOverflow_m")
                if isinstance(model, float):
                    expected.append(model)
            for pname in cell_names(what):
                if pname in station and not same_value(station[pname], mark):
                    out.append(Finding("C06", doc.name, no, f"отметка {cells[0]} ≠ {pname} = {station[pname]}"))
            if expected and not any(same_value(mark, e) for e in expected):
                out.append(Finding("C06", doc.name, no, f"отметка {cells[0]}: ожидается одно из {expected}"))
    # Раздел 1: порядок отметок
    for no, line in doc.section_lines("1"):
        m = re.search(r"Порядок `([^`]+)`", line)
        if m:
            nums = [doc_number(x) for x in m.group(1).split("<")]
            expected_order = [
                marks["LS103"],
                lt["LL"],
                lt["L"],
                station.get("rLvlStop_m"),
                station.get("rLvlStopAssist_m"),
                station.get("rLvlStartLead_m"),
                station.get("rLvlStartAssist_m"),
                lt["H"],
                lt["HH"],
                marks["LS102"],
            ]
            if len(nums) != len(expected_order) or not all(
                a is not None and isinstance(b, float) and same_value(a, b)
                for a, b in zip(nums, expected_order, strict=False)
            ):
                out.append(Finding("C06", doc.name, no, f"порядок отметок {m.group(1)} ≠ {expected_order}"))
    # Раздел 18.1: уставки устройств
    for t in doc.section_tables("18.1"):
        for no, cells in t.rows:
            out += _check_181_row(src, doc.name, no, cells)
    # Раздел 18.2: параметры станции и LIC101
    for t in doc.section_tables("18.2"):
        for no, cells in t.rows:
            names = cell_names(cells[2])
            if not names:
                continue
            raw = cells[3].strip("` ")
            unit = cells[4].strip()
            values = [v.strip("` ") for v in re.split(r"…", raw)] if len(names) == 2 else [raw]
            for pname, cell_val in zip(names, values, strict=False):
                pname = pname.split(".")[-1] if pname.startswith("stStationRetain.") else pname
                if pname in station:
                    exp: float | bool | str = station[pname]
                elif pname in pid:
                    exp = pid[pname]
                elif retain is not None and pname in retain.members and retain.members[pname].init:
                    exp = st_scalar(retain.members[pname].init or "")
                else:
                    out.append(
                        Finding(
                            "C06",
                            doc.name,
                            no,
                            f"параметра {pname} нет в ST_StationCfg, ST_StationRetain и stLIC101Cfg (DESIGN)",
                        )
                    )
                    continue
                got = _value_with_unit(cell_val, unit)
                if got is None or not same_value(got, exp):
                    out.append(Finding("C06", doc.name, no, f"{pname} = {cell_val} {unit}, в DESIGN — {exp}"))
    # Параметры станции в DESIGN, которых нет в таблице 18.2
    listed = set()
    for t in doc.section_tables("18.2"):
        for _no, cells in t.rows:
            listed |= {n.split(".")[-1] for n in cell_names(cells[2])}
    for pname in station:
        if pname not in listed and not pname.startswith(("ar", "at", "aui")):
            out.append(Finding("C06", "DESIGN.md", 0, f"поле ST_StationCfg.{pname} не описано в 04, раздел 18.2"))
    return out


def _value_with_unit(val: str, unit: str) -> float | bool | str | None:
    if val.upper() in ("TRUE", "FALSE"):
        return val.upper() == "TRUE"
    num = doc_number(val)
    if num is None:
        return val
    if unit in DOC_UNIT_S:
        return num * DOC_UNIT_S[unit]
    return num


def _check_181_row(src: Sources, doc: str, no: int, cells: list[str]) -> list[Finding]:
    m = re.match(r"(\w+): (.+)$", cells[0])
    if not m:
        return []
    tags = expand_pumps(m.group(1))
    labels = [x.strip() for x in re.split(r"\s*[;,/]\s*", m.group(2)) if x.strip()]
    values = [x.strip() for x in re.split(r"\s*[;/]\s*", cells[1]) if x.strip()]
    out: list[Finding] = []
    known = {"шкала", "HH", "H", "L", "LL", "задержка", "отметка"}
    if not any(lb.split()[0] in known for lb in labels):
        return out
    if len(labels) != len(values):
        return [Finding("C06", doc, no, f"«{cells[0]}»: {len(labels)} подписей и {len(values)} значений")]
    for tag in tags:
        row = src.io.by_tag.get(tag)
        dev = src.io.devices.get(tag)
        if row is None and dev is not None:
            row = next(r for r in src.io.rows if r["tag"] in dev.tags and r["device_type"])
        if row is None:
            out.append(Finding("C06", doc, no, f"{tag} нет в перечне"))
            continue
        for label, val in zip(labels, values, strict=True):
            key = label.split()[0]
            got = doc_number(val.split()[0]) if key != "шкала" else None
            if key == "шкала":
                lo, hi = (doc_number(x) for x in val.split("…"))
                if lo != doc_number(row["range_min"]) or hi != doc_number(row["range_max"]):
                    out.append(
                        Finding("C06", doc, no, f"{tag}: шкала {val}, в перечне {row['range_min']}…{row['range_max']}")
                    )
            elif key in ("HH", "H", "L", "LL"):
                exp = doc_number(row["sp_" + key.lower()])
                if exp is None or got is None or not same_value(got, exp):
                    out.append(Finding("C06", doc, no, f"{tag}: {key} = {val}, в перечне {row['sp_' + key.lower()]}"))
            elif key == "задержка":
                exp = doc_number(row["delay_on_s"])
                if exp is None or got is None or not same_value(got, exp):
                    out.append(Finding("C06", doc, no, f"{tag}: задержка {val}, в перечне {row['delay_on_s']}"))
            elif key == "отметка":
                mark = src.io.float_mark(tag)
                if mark is None or got is None or not same_value(got, mark):
                    out.append(Finding("C06", doc, no, f"{tag}: отметка {val}, в перечне {mark}"))
    return out


def sim_cfg_defaults(src: Sources) -> dict[str, float | bool | str]:
    out: dict[str, float | bool | str] = {}
    for tname in ("ST_SimCfg", "ST_PumpModelCfg"):
        t = src.design.types.get(tname)
        if t is None:
            continue
        for n, v in t.members.items():
            if v.init and not v.init.strip().startswith(("[", "(")):
                out[n] = st_scalar(v.init)
    return out


@check("C07", "уставки станционных тревог в 05 совпадают с перечнем и уставками станции")
def check_alarm_setpoints(src: Sources) -> list[Finding]:
    station = station_cfg_defaults(src)
    lt = src.io.setpoints("LT101")
    duty = station.get("uiDutyMax")
    out = []
    expected: dict[str, list[float | bool | str | None]] = {
        "KNS1.EHL": [src.io.float_mark("LS102"), lt.get("HH")],
        "KNS1.DRY": [src.io.float_mark("LS103"), lt.get("LL")],
        "KNS1.LDEV": [station.get(n) for n in ("rLdev102On_m", "rLdev102Off_m", "rLdev103On_m", "rLdev103Off_m")],
        "KNS1.UL1": [station.get("rUnderload_A"), station.get("rUnderloadSpeed_pct")],
        "KNS1.UL2": [station.get("rUnderload_A"), station.get("rUnderloadSpeed_pct")],
        "KNS1.UL3": [station.get("rUnderload_A"), station.get("rUnderloadSpeed_pct")],
        "KNS1.NORES": [duty + 1 if isinstance(duty, float) else None],
    }
    delays = {"KNS1.LDEV": station.get("tLdev"), "KNS1.UL1": station.get("tUnderload")}
    delays["KNS1.UL2"] = delays["KNS1.UL3"] = delays["KNS1.UL1"]
    for r in src.alarms:
        code = r["code"]
        if code in expected:
            text = re.sub(r"\(04 §[\d.]+\)|\b[A-Z]{2}\d{3}\b", "", r["setpoint"])
            got = [doc_number(x) for x in re.findall(r"\d+(?:[.,]\d+)?", text)]
            exp = expected[code]
            if len(got) != len(exp) or not all(
                g is not None and isinstance(e, float) and same_value(g, e) for g, e in zip(got, exp, strict=False)
            ):
                out.append(
                    Finding("C07", "05_alarm_list.csv", 0, f"{code}: уставка «{r['setpoint']}», ожидаются числа {exp}")
                )
        if code in delays and isinstance(delays[code], float):
            d = delays[code]
            if not same_value(float(r["delay_s"] or 0), d):  # type: ignore[arg-type]
                out.append(Finding("C07", "05_alarm_list.csv", 0, f"{code}: задержка {r['delay_s']}, в DESIGN {d}"))
        if r["source"] == "device" and r["tag"] in src.io.devices:
            out += _device_alarm_setpoint(src, r)
    return out


def _device_alarm_setpoint(src: Sources, r: dict[str, str]) -> list[Finding]:
    dev = src.io.devices[r["tag"]]
    suffix = r["code"].split(".", 1)[1]
    exp = device_cfg_expectations(src)
    run_row = next((x for x in src.io.rows if x["tag"] in dev.tags and x["role"] == "CMD_RUN"), None)
    expected: float | None = None
    if dev.dev_type in ("Motor", "MotorVfd"):

        def first(name: str, fallback: float) -> float:
            vals = [v for v in exp.get(name, []) if isinstance(v, float)]
            return vals[-1] if vals else fallback

        start = float(run_row["delay_on_s"]) if run_row and run_row["delay_on_s"] else first("tFbStart", 5.0)
        stop = float(run_row["delay_off_s"]) if run_row and run_row["delay_off_s"] else first("tFbStop", 5.0)
        expected = {
            "FTS": start,
            "UCR": start,
            "FTP": stop,
            "FBL": first("tFbLossFilter", 0.5),
            "COM": first("tCommLoss", 3.0),
            "SPD": first("rSpeedDev_pct", 10.0),
        }.get(suffix)
    if expected is None:
        return []
    got = doc_number(r["setpoint"])
    if got is None or not same_value(got, expected):
        return [Finding("C07", "05_alarm_list.csv", 0, f"{r['code']}: уставка {r['setpoint']}, ожидается {expected}")]
    return []


def pmi_checks(src: Sources) -> dict[str, tuple[int, str, str]]:
    """Проверки 06, раздел 5.6: номер → (строка, название, весь текст строки)."""
    out: dict[str, tuple[int, str, str]] = {}
    doc = src.docs.get("06_PMI.md")
    if doc is None:
        return out
    for t in doc.tables():
        if t.header[:2] == ["№", "Проверка"]:
            for no, cells in t.rows:
                if re.fullmatch(r"PMI-\d{2}", cells[0]):
                    out[cells[0]] = (no, cells[1], " | ".join(cells))
    return out


def pmi_ids(src: Sources) -> set[str]:
    return set(pmi_checks(src))


@check("C08", "проверки ПМИ: номера, названия в 07, приложение А, ссылки из других документов")
def check_pmi(src: Sources) -> list[Finding]:
    out: list[Finding] = []
    checks = pmi_checks(src)
    if not checks:
        return [Finding("C08", "06_PMI.md", 0, "не найдены таблицы проверок (раздел 5.6)")]
    n = len(checks)
    expected = {f"PMI-{i:02d}" for i in range(1, n + 1)}
    if set(checks) != expected:
        out.append(Finding("C08", "06_PMI.md", 0, f"номера проверок не идут подряд: {sorted(set(checks) ^ expected)}"))
    doc06 = src.docs["06_PMI.md"]
    appendix = {
        cells[0]: no
        for t in doc06.tables()
        if t.header and t.header[0] == "№" and len(t.header) > 2 and "Исполнение" in t.header[1]
        for no, cells in t.rows
    }
    if set(appendix) != set(checks):
        out.append(
            Finding(
                "C08",
                "06_PMI.md",
                0,
                f"приложение А не совпадает с разделом 5.6: {sorted(set(appendix) ^ set(checks))}",
            )
        )
    if "07_test_protocol.md" in src.docs:
        doc07 = src.docs["07_test_protocol.md"]
        rows = {
            cells[0]: (no, cells[1])
            for t in doc07.tables()
            for no, cells in t.rows
            if re.fullmatch(r"PMI-\d{2}", cells[0])
        }
        if set(rows) != set(checks):
            out.append(Finding("C08", doc07.name, 0, f"протокол не совпадает с 06: {sorted(set(rows) ^ set(checks))}"))
        for pid, (no, title) in rows.items():
            if pid in checks and checks[pid][1] != title:
                out.append(Finding("C08", doc07.name, no, f"{pid}: «{title}», в 06 — «{checks[pid][1]}»"))
    for name, no, line in all_texts(src):
        for ref in re.findall(r"PMI-(\d{2})(?!\d)", line):
            if f"PMI-{ref}" not in checks:
                out.append(Finding("C08", name, no, f"проверки PMI-{ref} нет в 06_PMI.md"))
        for m in re.finditer(r"`PMI-01`…`PMI-(\d{2})`", line):
            if int(m.group(1)) != n:
                out.append(Finding("C08", name, no, f"диапазон PMI-01…PMI-{m.group(1)}, проверок {n}"))
        for m in re.finditer(
            r"(?<![\d.,])(\d{2})(?:\s+(?:проверок|проверки|пунктов|сценариев|файлов)\b|\s*↔\s*\d{2})", line
        ):
            if int(m.group(1)) >= 25 and int(m.group(1)) != n and ("ПМИ" in line or "PMI" in line or "провер" in line):
                out.append(Finding("C08", name, no, f"число проверок {m.group(1)}, в 06 — {n}"))
        for m in re.finditer(
            r"(?:все проверки ПМИ|Проверок по программе|PMI-NN)\D{0,6}\((\d+)\)|Проверок по программе \| (\d+)", line
        ):
            num = int(m.group(1) or m.group(2))
            if num != n:
                out.append(Finding("C08", name, no, f"число проверок {num}, в 06 — {n}"))
    # 05 → 06: проверка, указанная у тревоги, упоминает эту тревогу (по шаблону насоса)
    for r in src.alarms:
        code = r["code"]
        norm = normalize_pump_code(code)
        for ref in re.findall(r"PMI-\d{2}", r["pmi"]):
            if ref not in checks:
                continue
            text = checks[ref][2]
            found = {
                normalize_pump_code(c)
                for c in re.findall(
                    r"(?:[A-Z]{1,4}\d{1,3}|[A-Z]{2}1n\d|P10n|KNS1|LIC101|V1)\.[A-Z][A-Z0-9]{0,6}n?", text
                )
            }
            found |= {normalize_pump_code(x) for c in list(found) for x in expand_pumps(c)}
            if norm not in found:
                out.append(
                    Finding("C08", "05_alarm_list.csv", 0, f"{code}: в колонке pmi {ref}, но проверка её не упоминает")
                )
    return out


def normalize_pump_code(code: str) -> str:
    code = re.sub(r"^P10[1-3n]\.", "P10n.", code)
    code = re.sub(r"^([A-Z]{2})1[1-3n](\d)\.", r"\g<1>1n\2.", code)
    return re.sub(r"^KNS1\.UL[1-3n]$", "KNS1.ULn", code)


def events_04(src: Sources) -> dict[int, tuple[int, str]]:
    doc = src.docs.get("04_algorithms.md")
    out: dict[int, tuple[int, str]] = {}
    if doc is None:
        return out
    for t in doc.section_tables("16"):
        if t.header and t.header[0] == "Номер":
            for no, cells in t.rows:
                if re.fullmatch(r"1010\d\d", cells[0]):
                    out[int(cells[0])] = (no, cells[1])
    return out


@check("C09", "события журнала (1010xx): таблица 04 §16, E_StationEvent DESIGN, ссылки")
def check_events(src: Sources) -> list[Finding]:
    out: list[Finding] = []
    events = events_04(src)
    enum = src.design.types.get("E_StationEvent")
    if enum is not None:
        design_set = {101000 + v for v in enum.values.values() if v is not None}
        if design_set != set(events):
            out.append(Finding("C09", "DESIGN.md", 0, f"E_StationEvent ≠ 04 §16: {sorted(design_set ^ set(events))}"))
    station_ids = {int(r["id"]) for r in src.alarms if r["source"] == "station"}
    for name, no, line in all_texts(src, svg=True):
        if name == "05_alarm_list.csv":
            continue
        for m in re.finditer(r"(?<![\d#])(10(?:0|1)\d{3})(?![\d.,])", line):
            num = int(m.group(1))
            if num in (100000, 101000):
                continue
            if 101000 < num < 102000 and num not in events:
                out.append(Finding("C09", name, no, f"события {num} нет в 04, раздел 16"))
            if 100000 < num < 101000 and num not in station_ids:
                out.append(Finding("C09", name, no, f"тревоги станции {num} нет в 05_alarm_list.csv"))
    return out


@check("C10", "пути переменных (GVL_…, сокращения документа) есть в DESIGN, выводе генератора и библиотеке")
def check_paths(src: Sources) -> list[Finding]:
    idx = src.symbols
    consts = design_constants(src.design)
    galias = global_aliases(idx)
    out = []
    for name, doc in src.docs.items():
        if name == "ASSUMPTIONS.md":
            continue
        aliases = dict(galias)
        aliases.update(doc_aliases(doc))
        for short in [a for a in aliases if a in idx.gvls]:
            aliases.pop(short)
        roots = set(idx.gvls) | set(aliases)
        for no, path, after in iter_doc_paths(doc, roots):
            for variant in expand_pumps(path):
                root = variant.split(".")[0].split("[")[0]
                full = aliases[root] + variant[len(root) :] if root in aliases and root not in idx.gvls else variant
                res = resolve_path(full, idx, consts)
                if not res.ok:
                    out.append(Finding("C10", name, no, f"`{path}`: {res.message}"))
                    break
                lit = re.match(r"\s*(?:=|<>)\s*((?:PL\.)?(?:E_\w+\.)?[A-Z]\w*)(?![\w.(#])", after)
                if lit and res.verified and lit.group(1) not in ("TRUE", "FALSE"):
                    err = check_enum_literal(idx, res.type, lit.group(1))
                    if err:
                        out.append(Finding("C10", name, no, f"`{path}` = {lit.group(1)}: {err}"))
                        break
    return out


def check_enum_literal(idx: StIndex, type_name: str, literal: str) -> str:
    t = idx.type_def(type_name)
    if t is None or t.kind != "enum":
        return ""
    parts = literal.replace("PL.", "").split(".")
    if len(parts) == 2 and parts[0] != t.name:
        return f"тип {parts[0]}, у поля {t.name}"
    if parts[-1] not in t.values:
        return f"нет значения {parts[-1]} в {t.name} ({', '.join(t.values)})"
    return ""


@check("C11", "литералы перечислений (E_X.Y и «поле = Y») существуют")
def check_enum_literals(src: Sources) -> list[Finding]:
    idx = src.symbols
    out = []
    field_enums: dict[str, set[str]] = {}
    for tdef in idx.types.values():
        for mname, var in tdef.members.items():
            td = idx.type_def(var.type)
            if td is not None and td.kind == "enum":
                field_enums.setdefault(mname, set()).add(td.name)
    for name, doc in src.docs.items():
        if name == "ASSUMPTIONS.md":
            continue
        for no, span, _after in doc.spans():
            for m in re.finditer(r"(?<![\w.])(?:PL\.)?(E_\w+)\.(\w+)", span):
                t = idx.types.get(m.group(1))
                if t is None:
                    out.append(Finding("C11", name, no, f"нет перечисления {m.group(1)}"))
                elif t.kind == "enum" and m.group(2) not in t.values:
                    out.append(Finding("C11", name, no, f"нет значения {m.group(2)} в {m.group(1)}"))
            rel = re.fullmatch(r"(\w+)\s*=\s*([A-Z]\w*)", span)
            if rel and len(field_enums.get(rel.group(1), set())) == 1 and rel.group(2) not in ("TRUE", "FALSE"):
                enum = next(iter(field_enums[rel.group(1)]))
                if rel.group(2) not in idx.types[enum].values:
                    out.append(Finding("C11", name, no, f"`{span}`: нет значения {rel.group(2)} в {enum}"))
    return out


def defined_objects(src: Sources) -> set[str]:
    names: set[str] = set()
    for idx in (src.design, src.library, src.generator):
        names |= set(idx.types) | set(idx.gvls)
    names |= {
        "GVL_IO",
        "GVL_Devices",
        "GVL_Hmi",
        "GVL_Persist",
        "GVL_CfgProject",
        "GVL_DevIdx",
        "PRG_Devices",
        "PRG_ApplyProjectCfg",
    }
    design = src.docs.get("DESIGN.md")
    if design is not None:
        plan = next((b for b in design.blocks if b.lang == "" and "src/" in b.text), None)
        if plan is not None:
            names |= set(re.findall(r"\b[A-Z]{1,3}_\w+", plan.text))
        for h in design.headings:
            names |= set(re.findall(r"`((?:FB|PRG|F|GVL|ST|E|I)_\w+)`", h.title))
    hmi = src.docs.get("08_hmi_spec.md")
    if hmi is not None:
        names |= set(re.findall(r"\b(?:TL|VIS)_\w+", hmi.text))
    return names | EXTERNAL_OBJECTS


@check(
    "C12",
    "имена объектов ST (FB_, PRG_, F_, GVL_, ST_, E_, I_, TL_, VIS_) объявлены в DESIGN, генераторе или библиотеке",
)
def check_object_names(src: Sources) -> list[Finding]:
    names = defined_objects(src)
    out = []
    for name, doc in src.docs.items():
        if name == "ASSUMPTIONS.md":
            continue
        for no, line in enumerate(doc.lines, 1):
            for m in re.finditer(r"(?<![\w.<])(?:PL\.)?((?:FB|PRG|F|GVL|ST|E|I|TL|VIS)_[A-Za-z0-9_]+)", line):
                token = m.group(1)
                if token.endswith("_") or line[m.end() : m.end() + 1] in ("<", "*"):
                    continue
                if token in names or (token.endswith("_Test") and token[: -len("_Test")] in names):
                    continue
                out.append(Finding("C12", name, no, f"объект {token} не объявлен (DESIGN, генератор, библиотека)"))
    return out


_CONST_RE = re.compile(r"(?<![\w.<*])([A-Z][A-Z0-9]*(?:_[A-Z0-9]+)+)(?![\w*<])")


@check("C13", "константы (STN_, KNS_, SIM_, MOT_…) объявлены в GVL_Const DESIGN или библиотеки")
def check_constants(src: Sources) -> list[Finding]:
    project = set(design_constants(src.design))
    library = set(src.library.gvls.get("GVL_Const", {}))
    skip = src.io.tags | src.io.roles | set(src.io.devices)
    out = []
    for name, doc in src.docs.items():
        if name == "ASSUMPTIONS.md":
            continue
        sources = [(no, span) for no, span, _ in doc.spans()]
        sources += [
            (b.line + k, line) for b in doc.blocks if b.lang == "st" for k, line in enumerate(b.text.splitlines())
        ]
        for no, text in sources:
            for m in _CONST_RE.finditer(text):
                token = m.group(1)
                if token in skip or token in EXTERNAL_CONSTANTS or token.startswith(EXTERNAL_CONST_PREFIXES):
                    continue
                if token.startswith(PROJECT_CONST_PREFIXES):
                    if token not in project and not (library and token in library):
                        out.append(Finding("C13", name, no, f"константы {token} нет в GVL_Const (DESIGN, раздел 2)"))
                elif token.startswith(LIBRARY_CONST_PREFIXES) and library and token not in library:
                    out.append(Finding("C13", name, no, f"константы {token} нет в PL.GVL_Const"))
    return out


def _numbered_names(lines: Iterable[tuple[int, str]], pattern: str) -> list[str]:
    out = []
    for _no, line in lines:
        m = re.match(pattern, line)
        if m:
            out.append(m.group(1))
    return out


@check("C14", "алгоритмы 04 разложены на ФБ DESIGN: разделы, перечисления, поля структур, порядок цикла")
def check_decomposition(src: Sources) -> list[Finding]:
    out: list[Finding] = []
    doc04 = src.docs.get("04_algorithms.md")
    design = src.docs.get("DESIGN.md")
    if doc04 is None or design is None:
        return out
    sections = doc04.section_numbers()
    covered: set[str] = set()
    for h in design.headings:
        m = re.search(r"\(04 (§.+?)\)", h.title)
        if not m:
            continue
        for ref in re.findall(r"(\d+(?:\.\d+)*)", m.group(1)):
            covered.add(ref)
            if ref not in sections:
                out.append(Finding("C14", design.name, h.line, f"раздела 04 §{ref} нет в 04_algorithms.md"))
    for req in REQUIRED_04_SECTIONS:
        if req not in sections:
            out.append(Finding("C14", doc04.name, 0, f"нет раздела {req}"))
        if not any(req == c or req.startswith(c + ".") for c in covered):
            out.append(
                Finding(
                    "C14", design.name, 0, f"раздел 04 §{req} не назначен ни одному ФБ (заголовки DESIGN, разделы 6–9)"
                )
            )
    # ФБ станции: план файлов ↔ разделы 6.x
    plan = next((b.text for b in design.blocks if b.lang == "" and "src/" in b.text), "")
    m = re.search(r"Station/\s+(PRG_Station.*?)К1", plan, re.S)
    planned = set(re.findall(r"\b(?:FB|F)_\w+", m.group(1))) if m else set()
    described = {
        mm.group(1)
        for h in design.headings
        if h.number.startswith("6.")
        for mm in [re.search(r"`((?:FB|F)_\w+)", h.title)]
        if mm
    }
    for fb in sorted(planned ^ described):
        out.append(
            Finding("C14", design.name, 0, f"{fb}: есть только в {'плане файлов' if fb in planned else 'разделе 6'}")
        )

    # Перечисления 04 ↔ DESIGN
    def enum_values(name: str) -> dict[str, int | None]:
        t = src.design.types.get(name)
        return t.values if t is not None else {}

    act = []
    for t in doc04.section_tables("4"):
        for _no, cells in t.rows:
            names = cell_names(cells[1]) if len(cells) > 1 else []
            if names:
                act.append(names[0])
    act_design = enum_values("E_ControlAct")
    if set(act) != set(act_design):
        out.append(Finding("C14", doc04.name, 0, f"раздел 4: {sorted(act)} ≠ E_ControlAct {sorted(act_design)}"))
    prec = next((h for h in design.headings if "FB_ControlSelector" in h.title), None)
    if prec is not None:
        text = " ".join(line for _no, line in design.section_lines(prec.number))
        m2 = re.search(r"Старшинство[^:]*:\s*(.+?)\.\s", text)
        if m2:
            order = re.findall(r"`(\w+)`", m2.group(1))
            auto_order = [a for a in act if a != "Manual"]
            if order != auto_order:
                out.append(Finding("C14", design.name, prec.line, f"старшинство {order} ≠ порядок 04 §4 {auto_order}"))
    for section, ename in (("5.1", "E_PumpRole"), ("8.1", "E_RotationMode")):
        names04 = [
            cell_names(cells[0])[0]
            for t in doc04.section_tables(section)
            for _no, cells in t.rows
            if cell_names(cells[0])
        ]
        if set(names04) != set(enum_values(ename)):
            out.append(
                Finding(
                    "C14", doc04.name, 0, f"раздел {section}: {sorted(names04)} ≠ {ename} {sorted(enum_values(ename))}"
                )
            )
    for t in doc04.section_tables("5.1"):
        for no, cells in t.rows:
            nm = cell_names(cells[0])
            if nm and doc_number(cells[1]) != enum_values("E_PumpRole").get(nm[0]):
                out.append(
                    Finding(
                        "C14",
                        doc04.name,
                        no,
                        f"{nm[0]} = {cells[1]}, в E_PumpRole — {enum_values('E_PumpRole').get(nm[0])}",
                    )
                )
    # 19.2 и 19.3 ↔ ST_StationCmd, ST_StationSts
    for section, tname in (("19.2", "ST_StationCmd"), ("19.3", "ST_StationSts")):
        listed = {n for t in doc04.section_tables(section) for _no, cells in t.rows for n in cell_names(cells[0])}
        members = {n for n in (src.design.types[tname].members if tname in src.design.types else {}) if n != "wReserve"}
        if listed != members:
            out.append(Finding("C14", doc04.name, 0, f"раздел {section} ≠ {tname}: {sorted(listed ^ members)}"))
    for t in doc04.section_tables("19.3"):
        for no, cells in t.rows:
            if "eControlAct" in cell_names(cells[0]):
                pairs = re.findall(r"(\d+) `(\w+)`", cells[1])
                got = {k: int(v) for v, k in pairs}
                if got and got != act_design:
                    out.append(Finding("C14", doc04.name, no, f"значения E_ControlAct {got} ≠ DESIGN {act_design}"))
            if "wState" in cell_names(cells[0]):
                out += _check_wstate_bits(src, doc04.name, no, cells[2])
    # 10.6 ↔ KNS_ILK_*
    consts = design_constants(src.design)
    for t in doc04.section_tables("10.6"):
        for no, cells in t.rows:
            nm = cell_names(cells[1]) if len(cells) > 1 else []
            if nm and nm[0] in consts:
                bit = doc_number(cells[0])
                val = st_scalar(consts[nm[0]].init or "")
                if bit is None or not isinstance(val, float) or int(val) != 1 << int(bit):
                    out.append(
                        Finding("C14", doc04.name, no, f"{nm[0]}: бит {cells[0]}, в DESIGN {consts[nm[0]].init}")
                    )
            elif nm and nm[0].startswith("KNS_"):
                out.append(Finding("C14", doc04.name, no, f"{nm[0]} нет в GVL_Const DESIGN"))
    # Порядок программ MainTask: 04 §2, DESIGN §12, ARCHITECTURE §9
    order04 = _numbered_names(doc04.section_lines("2"), r"\d+\.\s+`(PRG_\w+)`")
    cfg = next((b.text for b in design.blocks if b.lang == "json" and "MainTask" in b.text), "")
    m3 = re.search(r'"MainTask".*?"pous":\s*\[([^\]]*)\]', cfg, re.S)
    order_design = re.findall(r'"(PRG_\w+)"', m3.group(1)) if m3 else []
    if order04 != order_design:
        out.append(Finding("C14", doc04.name, 0, f"порядок MainTask {order04} ≠ DESIGN, раздел 12 {order_design}"))
    arch = src.docs.get("ARCHITECTURE.md")
    if arch is not None:
        for t in arch.section_tables("9"):
            for no, cells in t.rows:
                if cells[0] == "`MainTask`":
                    order_arch = re.findall(r"`(PRG_\w+)`", cells[3].split("(")[0])
                    if order_arch != order_design:
                        out.append(
                            Finding("C14", arch.name, no, f"порядок MainTask {order_arch} ≠ DESIGN {order_design}")
                        )
    return out


def _check_wstate_bits(src: Sources, doc: str, no: int, text: str) -> list[Finding]:
    consts = design_constants(src.design)
    bits = {}
    for name, var in consts.items():
        if name.startswith("STN_ST_") and var.init:
            val = st_scalar(var.init)
            if isinstance(val, float) and val > 0:
                bits[int(val).bit_length() - 1] = name
    out = []
    described = dict(re.findall(r"(\d+) ([^,]+)", text.split(":", 1)[-1]))
    for bit, name in sorted(bits.items()):
        desc = described.get(str(bit), "")
        word = WSTATE_KEYWORDS.get(name, "")
        if not desc or word.lower() not in desc.lower():
            out.append(Finding("C14", doc, no, f"бит {bit} wState: «{desc}», в DESIGN {name}"))
    if {int(b) for b in described} != set(bits):
        out.append(Finding("C14", doc, no, f"биты wState {sorted(int(b) for b in described)} ≠ DESIGN {sorted(bits)}"))
    return out


@check("C15", "биты `Sts.wState` в тексте ПМИ и HMI соответствуют константам STN_ST_* DESIGN")
def check_wstate_refs(src: Sources) -> list[Finding]:
    consts = design_constants(src.design)
    bits = {}
    for name, var in consts.items():
        if name.startswith("STN_ST_") and var.init:
            val = st_scalar(var.init)
            if isinstance(val, float) and val > 0:
                bits[int(val).bit_length() - 1] = name
    out = []
    for name, doc in src.docs.items():
        for no, line in doc.prose():
            for m in re.finditer(r"wState`?\s*\(?бит(?:ы)?\s+(\d+)(?:,\s*(\d+))?\)?(?:\s*\(([^)]*)\))?", line):
                for b in (m.group(1), m.group(2)):
                    if b is None:
                        continue
                    if int(b) not in bits:
                        out.append(Finding("C15", name, no, f"бита {b} нет среди STN_ST_* DESIGN"))
                    elif m.group(3) and m.group(2) is None:
                        word = WSTATE_KEYWORDS.get(bits[int(b)], "")
                        if word and word.lower() not in m.group(3).lower():
                            out.append(Finding("C15", name, no, f"бит {b} («{m.group(3)}») — это {bits[int(b)]}"))
    return out


@check("C16", "HMI: макеты SVG есть, подписаны «МАКЕТ», коды и тексты тревог на них — из 05; инъекции имитации полные")
def check_hmi(src: Sources) -> list[Finding]:
    out: list[Finding] = []
    hmi = src.docs.get("08_hmi_spec.md")
    codes = alarm_codes(src)
    if hmi is not None:
        for ref in sorted(set(re.findall(r"hmi/([\w.-]+\.svg)", hmi.text))):
            if ref not in src.svgs:
                out.append(Finding("C16", hmi.name, 0, f"нет файла docs/hmi/{ref}"))
    for name, text in src.svgs.items():
        texts = [re.sub(r"<[^>]+>", "", t).strip() for t in re.findall(r"<text[^>]*>(.*?)</text>", text, re.S)]
        texts = [
            t.replace("&amp;", "&").replace("&lt;", "<").replace("&gt;", ">").replace("&quot;", '"') for t in texts if t
        ]
        if not any("МАКЕТ" in t for t in texts):
            out.append(Finding("C16", f"hmi/{name}", 0, "нет подписи «МАКЕТ»"))
        for i, t in enumerate(texts[:-1]):
            if t not in codes:
                continue
            full = codes[t]["text_ru"]
            prefix = full.split(": ")[0]
            # полный текст тревоги (баннер, таблица) должен совпадать с 05; короткие подписи экрана насоса — нет
            if texts[i + 1].startswith(prefix) and texts[i + 1] != full:
                out.append(Finding("C16", f"hmi/{name}", 0, f"{t}: «{texts[i + 1]}», в 05 — «{full}»"))
    if hmi is not None:
        # 08 §2.2: время реакции и номер приоритета — как в 05 и в PL.E_AlarmPriority
        prio_enum = src.symbols.types.get("E_AlarmPriority")
        for table in hmi.section_tables("2.2"):
            for no, cells in table.rows:
                pm = re.match(r"(\w+) \((\d)\)", cells[0])
                if not pm or len(cells) < 4:
                    continue
                prio, num = pm.group(1), int(pm.group(2))
                if prio_enum is not None and prio_enum.values.get(prio) != num:
                    out.append(
                        Finding(
                            "C16", hmi.name, no, f"{prio} ({num}): в E_AlarmPriority — {prio_enum.values.get(prio)}"
                        )
                    )
                for r in src.alarms:
                    if r["priority"] == prio and r["response"] != cells[3]:
                        out.append(
                            Finding(
                                "C16",
                                "05_alarm_list.csv",
                                0,
                                f"{r['code']}: время реакции «{r['response']}», для {prio} в 08 — «{cells[3]}»",
                            )
                        )
    inj = src.design.types.get("ST_FaultInjection")
    if inj is not None:
        fields = set(inj.members)
        doc06 = src.docs.get("06_PMI.md")
        if doc06 is not None:
            listed = {
                re.sub(r"\[.*?\]", "", n).split(".")[-1]
                for t in doc06.section_tables("5.4")
                for _no, cells in t.rows
                for n in cell_names(cells[0])
            }
            missing = sorted(f for f in fields if f not in listed)
            if missing:
                out.append(Finding("C16", doc06.name, 0, f"раздел 5.4 не описывает поля ST_FaultInjection: {missing}"))
        if hmi is not None:
            text10 = " ".join(line for _no, line in hmi.section_lines("10"))
            missing = sorted(f for f in fields if not re.search(rf"\b{f}\b", text10))
            if missing:
                out.append(
                    Finding(
                        "C16",
                        hmi.name,
                        0,
                        f"экран «Имитация» (раздел 10) не привязывает поля ST_FaultInjection: {missing}",
                    )
                )
    return out


_DOC_REF_RE = re.compile(
    r"(?:\[[^\]]*\]\((?:docs/)?(?P<link>[\w.]+\.md)(?:#[^)]*)?\)|`?(?P<plain>01_TZ|02_functional_diagram|04_algorithms|06_PMI|08_hmi_spec|DESIGN|ARCHITECTURE)(?:\.md)?`?)"
    r",?\s+(?:раздел|разделы|подраздел)\s+(?P<num>\d+(?:\.\d+)*(?:(?:,\s*|\s+и\s+|–)\d+(?:\.\d+)*)*)"
)
_SECT_REF_RE = re.compile(
    r"(?<![\w.])(?P<doc>0[1-8])(?:_[A-Za-z_]+(?:\.md)?)? §\s?(?P<num>\d+(?:\.\d+)*(?:,\s*§?\d+(?:\.\d+)*)*)"
)


@check("C17", "ссылки «документ, раздел N» и «04 §N» указывают на существующие разделы; версии документов")
def check_cross_refs(src: Sources) -> list[Finding]:
    out = []
    numbers = {name: doc.section_numbers() for name, doc in src.docs.items()}
    versions = {}
    for name, doc in src.docs.items():
        m = re.search(r"версия (\d+\.\d+)", doc.text[:600])
        if m:
            versions[name] = m.group(1)
    alarm_csv = src.root / "docs" / "05_alarm_list.csv"
    csv_lines = list(enumerate(alarm_csv.read_text(encoding="utf-8").splitlines(), 1))
    sources: list[tuple[str, list[tuple[int, str]]]] = [
        (name, list(doc.prose())) for name, doc in src.docs.items() if name != "ASSUMPTIONS.md"
    ]
    sources.append(("05_alarm_list.csv", csv_lines))
    for name, lines in sources:
        for no, line in lines:
            for m in _DOC_REF_RE.finditer(line):
                target = m.group("link") or (m.group("plain") or "") + ".md"
                if target not in numbers:
                    continue
                for num in re.findall(r"\d+(?:\.\d+)*", m.group("num")):
                    if num not in numbers[target]:
                        out.append(Finding("C17", name, no, f"в {target} нет раздела {num}"))
            for m in _SECT_REF_RE.finditer(line):
                target = DOC_SHORT.get(m.group("doc"), "")
                if target not in numbers:
                    continue
                for num in re.findall(r"\d+(?:\.\d+)*", m.group("num")):
                    if num not in numbers[target]:
                        out.append(
                            Finding("C17", name, no, f"в {target} нет раздела {num} (ссылка {m.group('doc')} §{num})")
                        )
            for m in re.finditer(
                r"\[?(\d\d_\w+\.md|DESIGN\.md|ARCHITECTURE\.md)\]?(?:\([^)]*\))?`?\s+v(\d+\.\d+)", line
            ):
                if m.group(1) in versions and versions[m.group(1)] != m.group(2):
                    out.append(
                        Finding(
                            "C17", name, no, f"{m.group(1)} v{m.group(2)}, у документа — версия {versions[m.group(1)]}"
                        )
                    )
    return out


@check("C18", "таблицы Markdown: одинаковое число колонок в строках")
def check_tables(src: Sources) -> list[Finding]:
    out = []
    for name, doc in [*src.docs.items(), ("03_io_list.md", src.io_md)]:
        for t in doc.tables():
            for no, cells in t.rows:
                if len(cells) != len(t.header):
                    out.append(Finding("C18", name, no, f"{len(cells)} ячеек, в заголовке {len(t.header)}"))
    return out


@check("C19", "числа в ТЗ: сигналы, устройства, тревоги совпадают с перечнем и 05")
def check_counts(src: Sources) -> list[Finding]:
    out = []
    n_dev_alarms = sum(1 for r in src.alarms if r["source"] == "device")
    n_station = sum(1 for r in src.alarms if r["tag"] == "KNS1")
    for name, no, line in all_texts(src):
        for m in re.finditer(r"(\d+) сигнал\w*,\s*(\d+) устройств", line):
            if int(m.group(1)) != len(src.io.rows) or int(m.group(2)) != len(src.io.devices):
                out.append(
                    Finding(
                        "C19",
                        name,
                        no,
                        f"{m.group(0)}: в перечне {len(src.io.rows)} сигналов, {len(src.io.devices)} устройств",
                    )
                )
        for m in re.finditer(r"(\d+) тревог \((\d+) устройств \+ (\d+) станции\)", line):
            got = tuple(int(x) for x in m.groups())
            exp = (n_dev_alarms + n_station, n_dev_alarms, n_station)
            if got != exp:
                out.append(Finding("C19", name, no, f"{m.group(0)}: в 05 {exp}"))
    return out


ELEM_SIZE = {
    "BOOL": 1,
    "BYTE": 1,
    "SINT": 1,
    "USINT": 1,
    "WORD": 2,
    "INT": 2,
    "UINT": 2,
    "DWORD": 4,
    "DINT": 4,
    "UDINT": 4,
    "REAL": 4,
    "TIME": 4,
    "LWORD": 8,
    "LINT": 8,
    "ULINT": 8,
    "LREAL": 8,
    "LTIME": 8,
}


def type_layout(idx: StIndex, type_name: str, consts: dict[str, Var]) -> tuple[int, int, bool] | None:
    """(размер, выравнивание, без скрытых вставок) по естественному выравниванию; None — тип неизвестен."""
    name = base_type_name(type_name)
    arr = array_info(name)
    if arr is not None:
        lo, hi = resolve_bound(arr[0], consts), resolve_bound(arr[1], consts)
        elem = type_layout(idx, arr[2], consts)
        if lo is None or hi is None or elem is None:
            return None
        return elem[0] * (hi - lo + 1), elem[1], elem[2]
    if name.upper() in ELEM_SIZE:
        return ELEM_SIZE[name.upper()], ELEM_SIZE[name.upper()], True
    t = idx.type_def(name)
    if t is None:
        return None
    if t.kind == "enum":
        return 2, 2, True
    if t.kind != "struct":
        return None
    offset, align, packed = 0, 1, True
    for var in t.members.values():
        lay = type_layout(idx, var.type, consts)
        if lay is None:
            return None
        size, al, inner = lay
        aligned = -(-offset // al) * al
        packed = packed and inner and aligned == offset
        offset = aligned + size
        align = max(align, al)
    total = -(-offset // align) * align
    return total, align, packed and total == offset


@check("C20", "структуры обмена: размер в документах совпадает с объявлением DESIGN, без скрытого выравнивания")
def check_layouts(src: Sources) -> list[Finding]:
    idx = src.symbols
    consts = design_constants(src.design)
    claims: list[tuple[str, int, str, int]] = []
    design = src.docs.get("DESIGN.md")
    if design is not None:
        for block in design.blocks:
            for k, line in enumerate(block.text.splitlines()):
                m = re.match(r"TYPE (\w+) :.*?(\d+) байт", line)
                if m:
                    claims.append(("DESIGN.md", block.line + k, m.group(1), int(m.group(2))))
                    if "16/32 бит" in line:
                        lay = type_layout(idx, m.group(1), consts)
                        leaves = idx.members_of(m.group(1)) or {}
                        bad = [
                            n
                            for n, v in leaves.items()
                            if (type_layout(idx, v.type, consts) or (0, 0, True))[1] not in (2, 4)
                        ]
                        if bad or (lay is not None and not lay[2]):
                            claims.append(("DESIGN.md", block.line + k, m.group(1), -1))
    for name, doc in src.docs.items():
        for no, line in doc.prose():
            for m in re.finditer(r"`(ST_\w+)`\s*\([^)]*?(\d+) байт", line):
                claims.append((name, no, m.group(1), int(m.group(2))))
            for m in re.finditer(r"записей × (\d+) байт", line):
                claims.append((name, no, "ST_EventRecord", int(m.group(1))))
            for m in re.finditer(r"`(\w+)SizeIs(\d+)`", line):
                claims.append((name, no, "ST_" + m.group(1), int(m.group(2))))
    out = []
    for where, no, tname, size in claims:
        lay = type_layout(idx, tname, consts)
        if size == -1:
            out.append(
                Finding("C20", where, no, f"{tname}: обещаны только 16/32-битные поля без выравнивания — это не так")
            )
        elif lay is None:
            out.append(Finding("C20", where, no, f"{tname}: размер не вычисляется (тип не объявлен в DESIGN)"))
        elif lay[0] != size:
            out.append(Finding("C20", where, no, f"{tname}: {size} байт в документе, по объявлению — {lay[0]}"))
    return out


# --------------------------------------------------------------------------------------------------
# Запуск
# --------------------------------------------------------------------------------------------------


def run_checks(src: Sources, only: Sequence[str] = ()) -> list[Finding]:
    findings: list[Finding] = []
    for code, (_title, fn) in CHECKS.items():
        if only and code not in only:
            continue
        findings += fn(src)
    return findings


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Сверка документов КНС-1 (docs/01–08, ARCHITECTURE, DESIGN)")
    parser.add_argument("--root", type=Path, default=REPO_ROOT, help="корень репозитория")
    parser.add_argument("--check", action="append", default=[], help="только эта проверка (C01…); можно повторять")
    parser.add_argument("--list", action="store_true", help="список проверок")
    parser.add_argument(
        "--dump-library",
        type=Path,
        metavar="PL_REPO",
        help="записать снимок символов plc-process-lib из исходников репозитория в tools_project/data",
    )
    parser.add_argument(
        "--label", default="plc-process-lib", help="источник снимка (версия, коммит) для --dump-library"
    )
    args = parser.parse_args(argv)
    if args.list:
        for code, (title, _fn) in CHECKS.items():
            print(f"{code}  {title}")
        return 0
    if args.dump_library:
        idx = library_index_from_repo(args.dump_library)
        LIB_SNAPSHOT.parent.mkdir(parents=True, exist_ok=True)
        data = {"source": args.label, **idx.to_json()}
        LIB_SNAPSHOT.write_text(json.dumps(data, ensure_ascii=False, indent=1) + "\n", encoding="utf-8", newline="\n")
        print(f"записан {LIB_SNAPSHOT}")
        return 0
    src = load_sources(args.root)
    findings = run_checks(src, args.check)
    for note in src.notes:
        print(f"примечание: {note}")
    for f in findings:
        print(f)
    print(f"проверок: {len(args.check) or len(CHECKS)}, расхождений: {len(findings)}")
    return 1 if findings else 0


if __name__ == "__main__":
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    raise SystemExit(main())


__all__ = [
    "CHECKS",
    "IOLISTGEN_SETS",
    "Doc",
    "Finding",
    "IoList",
    "Sources",
    "StIndex",
    "derive_generator_index",
    "design_index",
    "find_repo",
    "generated_gvl_index",
    "library_index_from_repo",
    "load_sources",
    "parse_st",
    "run_checks",
    "run_iolistgen",
]
