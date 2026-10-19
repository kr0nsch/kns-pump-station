"""Значения ПЛК в сценариях: литералы CODESYS, перечисления, сравнения (DESIGN, раздел 14.3).

Литералы — как в ST и в ``cds_common.plc_value`` инструментов: ``TRUE``/``FALSE``, ``INT#5``, ``REAL#1.5``,
перечисления ``E_MotorState.Fault`` и ``PL.E_MotorState.Fault`` (по таблице ``enums.py``, которую генерирует
``tools_project/gen_enums.py``), числа и строки в одинарных кавычках. В сценариях нет «магических» чисел для
состояний: только имена перечислений.

Длительности — в единицах ПЛК: ``T#10M`` / ``TIME#…`` — целые миллисекунды (``TIME`` в CODESYS — 32-битное
число мс, сервер OPC UA отдаёт и принимает его числом), ``LTIME#…`` / ``LT#…`` — целые наносекунды. Так запись
``Cfg.tMaxContRun = T#10M`` (PMI-11) доходит до ПЛК как 600 000 мс, а не 600, и сравнение с прочитанным
значением идёт в тех же единицах. ``parse_time`` — та же длительность в секундах (выдержки сценария).
"""

from __future__ import annotations

import math
import re
from collections.abc import Mapping

PlcValue = bool | int | float | str
EnumTable = Mapping[str, Mapping[str, int]]

OPERATORS = ("=", "<>", "<", "<=", ">", ">=", "&", "!&")
_TYPED_RE = re.compile(r"^(?P<type>[A-Za-z_]+)#(?P<value>.+)$")
_TIME_RE = re.compile(r"(?P<num>\d+(?:\.\d+)?)(?P<unit>MS|US|NS|D|H|M|S)", re.IGNORECASE)
_TIME_UNITS = {"D": 86400.0, "H": 3600.0, "M": 60.0, "S": 1.0, "MS": 1e-3, "US": 1e-6, "NS": 1e-9}
_TIME_TYPES = ("T", "TIME")
_LTIME_TYPES = ("LT", "LTIME")
MS_PER_S = 1000
NS_PER_S = 1_000_000_000
_INT_TYPES = ("SINT", "USINT", "INT", "UINT", "DINT", "UDINT", "LINT", "ULINT", "BYTE", "WORD", "DWORD", "LWORD")
_REAL_TYPES = ("REAL", "LREAL")
_ENUM_RE = re.compile(r"^(?:PL\.)?(?P<type>E_\w+)\.(?P<value>\w+)$")
_REL_TOL = 1e-6


class LiteralError(ValueError):
    """Литерал не разобран: неизвестное перечисление, тип или формат."""


def parse_time(text: str) -> float:
    """Длительность ``T#1H30M5S500MS`` (без префикса тоже) → секунды."""
    body = text.split("#", 1)[1] if "#" in text else text
    body = body.replace("_", "")
    pos = 0
    total = 0.0
    for m in _TIME_RE.finditer(body):
        if m.start() != pos:
            raise LiteralError(f"длительность {text!r}: не разобрано «{body[pos : m.start()]}»")
        total += float(m.group("num")) * _TIME_UNITS[m.group("unit").upper()]
        pos = m.end()
    if pos != len(body) or pos == 0:
        raise LiteralError(f"длительность {text!r}: ожидается вида T#1M30S")
    return total


def _number(text: str) -> int | float:
    t = text.replace("_", "")
    if re.fullmatch(r"[-+]?\d+", t):
        return int(t)
    if re.fullmatch(r"16#[0-9A-Fa-f]+", t):
        return int(t[3:], 16)
    if re.fullmatch(r"2#[01]+", t):
        return int(t[2:], 2)
    try:
        return float(t)
    except ValueError:
        raise LiteralError(f"не число: {text!r}") from None


def parse_literal(text: str | PlcValue, enums: EnumTable | None = None) -> PlcValue:
    """Литерал сценария → значение Python (``bool``, ``int``, ``float``, ``str``)."""
    if not isinstance(text, str):
        return text
    t = text.strip()
    if t.upper() in ("TRUE", "FALSE"):
        return t.upper() == "TRUE"
    if len(t) >= 2 and t[0] == t[-1] == "'":
        return t[1:-1]
    enum = _ENUM_RE.match(t)
    if enum is not None:
        table = (enums or {}).get(enum.group("type"))
        if table is None:
            raise LiteralError(f"перечисление {enum.group('type')} неизвестно (enums.py: tools_project/gen_enums.py)")
        if enum.group("value") not in table:
            raise LiteralError(f"{enum.group('type')}: нет значения {enum.group('value')}")
        return table[enum.group("value")]
    typed = _TYPED_RE.match(t)
    if typed is not None and not t.startswith(("16#", "2#", "8#")):
        kind, value = typed.group("type").upper(), typed.group("value")
        if kind in _TIME_TYPES:
            return round(parse_time(t) * MS_PER_S)
        if kind in _LTIME_TYPES:
            return round(parse_time(t) * NS_PER_S)
        if kind == "BOOL":
            return value.upper() in ("TRUE", "1")
        if kind in _INT_TYPES:
            number = _number(value)
            if not isinstance(number, int):
                raise LiteralError(f"{text!r}: целый тип с дробным значением")
            return number
        if kind in _REAL_TYPES:
            return float(_number(value))
        raise LiteralError(f"неизвестный тип литерала {kind!r} в {text!r}")
    return _number(t)


def _equal(actual: PlcValue, expected: PlcValue) -> bool:
    if isinstance(actual, float) or isinstance(expected, float):
        if isinstance(actual, str) or isinstance(expected, str):
            return False
        a, e = float(actual), float(expected)
        return math.isclose(a, e, rel_tol=_REL_TOL, abs_tol=_REL_TOL)
    return actual == expected


def compare(actual: PlcValue, op: str, expected: PlcValue) -> bool:
    """Сравнение значения ПЛК с ожидаемым: ``=``, ``<>``, ``<``, ``<=``, ``>``, ``>=``; ``&`` — есть общие биты,
    ``!&`` — общих битов нет (бит снят: ``wState !& 16#0400``)."""
    if op == "=":
        return _equal(actual, expected)
    if op == "<>":
        return not _equal(actual, expected)
    if op in ("&", "!&"):
        if isinstance(actual, bool | float | str) or isinstance(expected, bool | float | str):
            raise LiteralError(f"маска {op} — только для целых")
        return ((actual & expected) != 0) == (op == "&")
    if isinstance(actual, str) or isinstance(expected, str):
        raise LiteralError(f"сравнение {op} строк не поддержано")
    a, e = float(actual), float(expected)
    if op == "<":
        return a < e
    if op == "<=":
        return a <= e or _equal(actual, expected)
    if op == ">":
        return a > e
    if op == ">=":
        return a >= e or _equal(actual, expected)
    raise LiteralError(f"неизвестная операция {op!r}; допустимо {', '.join(OPERATORS)}")
