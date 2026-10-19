"""Уставки LIC101 по умолчанию и инициализатор блока станции ``GVL_Persist`` — одно значение (DESIGN, раздел 4.2).

``GVL_StationDefaults.stLIC101Cfg`` (команда «Применить уставки проекта», 04 §18.3) и инициализатор
``stLIC101Cfg`` блока станции ``GVL_Persist`` (``tools_project/persist_station.txt``, из него iolistgen пишет
``src/GVLs/Generated/GVL_Persist.pvl.st``) ведутся двумя копиями текста: первый старт ПЛК берёт уставки из
инициализатора, команда — из констант. Тест сверяет их поле за полем, без CODESYS; второй тест проверяет, что
сверка замечает расхождение.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Any

import check_docs_consistency as C

ROOT = Path(__file__).resolve().parents[1]
DEFAULTS = ROOT / "src" / "GVLs" / "Station" / "GVL_StationDefaults.gvl.st"
PERSIST_BLOCK = ROOT / "tools_project" / "persist_station.txt"
PERSIST_GVL = ROOT / "src" / "GVLs" / "Generated" / "GVL_Persist.pvl.st"
NAME = "stLIC101Cfg"


def initializer_text(st_text: str, name: str) -> str:
    """Текст инициализатора ``name : <тип> := (...)`` — до парной закрывающей скобки (вне строк)."""
    text = C.strip_st_comments(st_text)
    m = re.search(rf"\b{re.escape(name)}\s*:\s*[\w.]+\s*:=\s*\(", text)
    assert m, f"нет объявления {name} с инициализатором"
    start = m.end() - 1
    depth = 0
    quote = ""
    for i in range(start, len(text)):
        c = text[i]
        if quote:
            if c == quote:
                quote = ""
        elif c in "'\"":
            quote = c
        elif c in "([":
            depth += 1
        elif c in ")]":
            depth -= 1
            if depth == 0:
                return text[start : i + 1]
    raise AssertionError(f"{name}: инициализатор без закрывающей скобки")


def initializer(path: Path, name: str = NAME) -> dict[str, Any]:
    value = C.parse_initializer(initializer_text(path.read_text(encoding="utf-8"), name))
    assert isinstance(value, dict), f"{path.name}: {name} — не структура"
    return value


def _norm(value: Any) -> Any:
    if isinstance(value, dict):
        return {k: _norm(v) for k, v in value.items()}
    if isinstance(value, list):
        return [_norm(v) for v in value]
    return " ".join(str(value).split())


def field_diff(a: dict[str, Any], b: dict[str, Any]) -> list[str]:
    """Поля, которые есть только в одном инициализаторе или различаются (значения без учёта пробелов)."""
    na, nb = _norm(a), _norm(b)
    out = [f"{k}: только в первом" for k in sorted(set(na) - set(nb))]
    out += [f"{k}: только во втором" for k in sorted(set(nb) - set(na))]
    out += [f"{k}: {na[k]!r} ≠ {nb[k]!r}" for k in sorted(set(na) & set(nb)) if na[k] != nb[k]]
    return out


def test_station_defaults_match_persist_init() -> None:
    defaults = initializer(DEFAULTS)
    assert defaults, "пустой инициализатор GVL_StationDefaults.stLIC101Cfg"
    for path in (PERSIST_BLOCK, PERSIST_GVL):
        diff = field_diff(defaults, initializer(path))
        assert not diff, f"GVL_StationDefaults.stLIC101Cfg и {path.name}: " + "; ".join(diff)


def test_drift_is_detected() -> None:
    text = DEFAULTS.read_text(encoding="utf-8")
    drifted = C.parse_initializer(initializer_text(text.replace("rKp := 6.0", "rKp := 5.0"), NAME))
    astalarm = C.parse_initializer(
        initializer_text(text.replace("PL.E_AlarmPriority.None)]", "PL.E_AlarmPriority.Low)]"), NAME)
    )
    reference = initializer(PERSIST_BLOCK)
    assert field_diff(drifted, reference) == ["rKp: '5.0' ≠ '6.0'"]
    assert [d.split(":")[0] for d in field_diff(astalarm, reference)] == ["astAlarm"]
    assert field_diff({"rKp": "6.0"}, {"rKp": "6.0", "rTi_s": "600.0"}) == ["rTi_s: только во втором"]
