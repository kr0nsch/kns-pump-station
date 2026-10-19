"""Коды тревог в CSV журнала (``F_AlarmCode``, DESIGN, раздел 9.2) — по тем же правилам, что генератор и 05.

Таблицы суффиксов слотов ``F_AlarmCode`` (константы в ``src/POUs/Log/F_AlarmCode``) сверяются без CODESYS:
каждая тревога устройства в ``docs/alarms.csv`` (вывод iolistgen по шаблонам plc-process-lib 1.0) получает тот
же код ``<TAG>.<SUFFIX>`` по типу устройства из ``GVL_DeviceList``; тревоги станции и LIC101 из
``docs/05_alarm_list.csv`` — ``KNS1.<SUFFIX>`` и ``LIC101.<SUFFIX>``; при доступных исходниках библиотеки —
таблица ``docs/alarm_templates.csv`` контракта целиком.
"""

from __future__ import annotations

import csv
import re
from pathlib import Path

import pytest

import check_docs_consistency as C

ROOT = Path(__file__).resolve().parents[1]
ALARM_CODE = ROOT / "src" / "POUs" / "Log" / "F_AlarmCode" / "F_AlarmCode.decl.st"
DEVICE_LIST = ROOT / "src" / "GVLs" / "Generated" / "GVL_DeviceList.gvl.st"
TYPE_TABLE = {
    "AnalogInput": "AI_SUFFIX",
    "DigitalInput": "DI_SUFFIX",
    "Motor": "MOT_SUFFIX",
    "MotorVfd": "MOT_SUFFIX",
    "Valve": "VLV_SUFFIX",
    "ControlValve": "CV_SUFFIX",
    "Pid": "PID_SUFFIX",
}
_ARRAY_RE = re.compile(r"(\w+)\s*:\s*ARRAY\s*\[[^\]]*\]\s*OF\s+STRING\([^)]*\)\s*:=\s*\[([^\]]*)\]", re.S)


def suffix_tables() -> dict[str, list[str]]:
    text = ALARM_CODE.read_text(encoding="utf-8")
    return {m.group(1): re.findall(r"'([^']*)'", m.group(2)) for m in _ARRAY_RE.finditer(text)}


def device_types() -> dict[str, str]:
    """Тег → PL.E_DeviceType по GVL_DeviceList (порядок asTag и aeDevType один)."""
    text = DEVICE_LIST.read_text(encoding="utf-8")
    tags = re.findall(r"'([A-Z0-9_]+)'", text[text.index("asTag") : text.index("auiDevNo")])
    types = re.findall(r"PL\.E_DeviceType\.(\w+)", text[text.index("aeDevType :") :])
    assert len(tags) == len(types) > 0
    return dict(zip(tags, types, strict=True))


def csv_rows(path: Path) -> list[dict[str, str]]:
    lines = [ln for ln in path.read_text(encoding="utf-8").splitlines() if ln.strip() and not ln.startswith("#")]
    return list(csv.DictReader(lines, delimiter=";"))


def test_tables_have_eight_slots_and_station_table_matches_count() -> None:
    tables = suffix_tables()
    for name in set(TYPE_TABLE.values()):
        assert len(tables[name]) == 8, f"{name}: слоты 0…ALM_SLOT_MAX"
    assert len(tables["STN_SUFFIX"]) == 13  # GVL_Const.STN_ALARM_COUNT (04 §15)


def test_device_alarm_codes_match_generated_alarm_list() -> None:
    tables, types = suffix_tables(), device_types()
    rows = csv_rows(ROOT / "docs" / "alarms.csv")
    assert rows
    for row in rows:
        tag, slot = row["tag"], int(row["slot"])
        suffix = tables[TYPE_TABLE[types[tag]]][slot] or str(slot)
        assert f"{tag}.{suffix}" == row["code"], f"id {row['id']}: F_AlarmCode даст {tag}.{suffix}"


def test_station_and_pid_codes_match_alarm_list_05() -> None:
    tables = suffix_tables()
    rows = [r for r in csv_rows(ROOT / "docs" / "05_alarm_list.csv") if r["source"] == "station"]
    assert len(rows) == 14
    for row in rows:
        slot = int(row["slot"])
        if row["tag"] == "KNS1":
            assert row["code"] == f"KNS1.{tables['STN_SUFFIX'][slot - 1]}", row["id"]
        else:
            assert row["code"] == f"LIC101.{tables['PID_SUFFIX'][slot]}", row["id"]


def test_tables_match_library_alarm_templates() -> None:
    repo = C.find_repo("PL_REPO", "plc-process-lib", ROOT, "docs/alarm_templates.csv")
    if repo is None:
        pytest.skip("нет исходников plc-process-lib (PL_REPO): сверка с шаблонами тревог библиотеки пропущена")
    tables = suffix_tables()
    templates = csv_rows(repo / "docs" / "alarm_templates.csv")
    assert templates
    for row in templates:
        assert tables[TYPE_TABLE[row["type"]]][int(row["slot"])] == row["suffix"], row
