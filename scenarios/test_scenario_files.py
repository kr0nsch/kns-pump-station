"""Файлы сценариев ПМИ без ПЛК (CI, DESIGN, раздел 14.3): схема, номер и ускорение по 06_PMI, приложение А;
пути переменных существуют (объявления src/, DESIGN и снимок plc-process-lib), запись — только туда, где
символьная конфигурация сборки sim даёт ReadWrite; коды тревог — из 05_alarm_list.csv; литералы
перечислений — из enums.py. Подстановки ``{имя}`` перебираются номерами насосов 1…3.
"""

from __future__ import annotations

import json
import re
from collections.abc import Iterator
from pathlib import Path
from typing import Any

import pytest

import check_docs_consistency as C
import symbol_config as S
from kns_scenarios.alarms import load_alarm_list
from kns_scenarios.context import _EXPR_RE
from kns_scenarios.enums import ENUMS
from kns_scenarios.scenario import Scenario, load_scenario
from kns_scenarios.values import parse_literal

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
FILES = sorted([*(HERE / "examples").glob("PMI-*.toml"), *(HERE / "pmi").glob("PMI-*.toml")])
PMI_COUNT = 39  # 06_PMI, приложение А
PUMPS = (1, 2, 3)
_PLACEHOLDER = re.compile(r"\{\w+\}")


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


def pmi_table() -> dict[str, float]:
    """Номер → k из приложения А 06_PMI."""
    text = (ROOT / "docs" / "06_PMI.md").read_text(encoding="utf-8")
    appendix = text[text.index("## Приложение А") :]
    out: dict[str, float] = {}
    for m in re.finditer(r"^\| (PMI-\d\d) \|[^|]*\| (\d+) \|", appendix, re.MULTILINE):
        out[m.group(1)] = float(m.group(2))
    return out


def expand(text: str) -> list[str]:
    """Подстановки {имя} номерами насосов 1…3 (как check_docs_consistency для P10n)."""
    if not _PLACEHOLDER.search(text):
        return [text]
    return [_PLACEHOLDER.sub(str(n), text) for n in PUMPS]


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


def test_writable_respects_member_rules() -> None:
    assert writable("GVL_Log.stEventFeed.udiFromSeq") and writable("GVL_Log.stEventView.uiPage")
    assert not writable("GVL_Log.stEventFeed.udiSeqLast") and not writable("GVL_Log.stEventView.astRow[1].udiSeq")
    assert writable("GVL_Sim.stFaultInj.axVfdFault[2]") and not writable("GVL_IO.xLS102")


def walk_steps(steps: list[dict[str, Any]]) -> Iterator[dict[str, Any]]:
    for step in steps:
        yield step
        yield from walk_steps(step.get("steps", []))


def reads_and_writes(sc: Scenario) -> tuple[list[str], list[str], list[str], list[str]]:
    """Пути чтения, пути записи, коды тревог, литералы выражений сценария."""
    reads: list[str] = []
    writes: list[str] = []
    codes: list[str] = []
    literals: list[str] = []
    for step in walk_steps(sc.steps):
        writes += list(step.get("write", {}))
        pulses = step.get("pulse", [])
        writes += pulses if isinstance(pulses, list) else [pulses]
        reads += list(step.get("capture", {}).values())
        exprs = [step["wait"]] if "wait" in step else []
        exprs += list(step.get("expect", []))
        for expr in exprs:
            m = _EXPR_RE.match(expr)
            assert m is not None, f"{sc.id}: выражение «{expr}» не разобрано"
            reads.append(m.group("path"))
            literals.append(m.group("lit"))
        if "wait_alarm" in step:
            codes.append(step["wait_alarm"]["code"])
        delay = step.get("expect_delay", {})
        codes += [delay[k] for k in ("alarm", "from_alarm") if k in delay]
    return reads, writes, codes, literals


@pytest.mark.parametrize("path", FILES, ids=[f.parent.name + "/" + f.stem for f in FILES])
def test_scenario_file(path: Path) -> None:
    sc = load_scenario(path)
    table = pmi_table()
    assert sc.id == path.stem, "имя файла = номер проверки"
    assert sc.id in table, f"{sc.id} нет в приложении А 06_PMI.md"
    assert sc.time_scale == table[sc.id], f"k = {sc.time_scale}, в приложении А — {table[sc.id]}"
    reads, writes, codes, literals = reads_and_writes(sc)
    for template in reads + writes:
        for p in expand(template):
            res = C.resolve_path(p, INDEX, CONSTS)
            assert res.ok, f"{sc.id}: путь {p}: {res.message}"
    for template in writes:
        for p in expand(template):
            assert writable(p), f"{sc.id}: запись в {p} закрыта символами (sim)"
    for template in codes:
        for code in expand(template):
            assert code in ALARMS, f"{sc.id}: тревоги {code} нет в 05_alarm_list.csv"
    for template in literals:
        for literal in expand(template):
            parse_literal(literal, ENUMS)  # LiteralError — неизвестное перечисление


def test_pmi_catalogue_complete_when_present() -> None:
    files = sorted((HERE / "pmi").glob("PMI-*.toml"))
    if not files:
        pytest.skip("сценарии ПМИ scenarios/pmi/ ещё не добавлены (команда модели)")
    ids = {f.stem for f in files}
    assert ids == set(pmi_table()) and len(ids) == PMI_COUNT, "каждому пункту 06 — файл сценария"
