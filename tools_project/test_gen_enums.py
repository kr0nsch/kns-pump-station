"""Таблица перечислений сценариев (scenarios/kns_scenarios/enums.py) совпадает с генерацией gen_enums.py."""

from __future__ import annotations

import gen_enums as G


def test_enums_table_is_up_to_date() -> None:
    assert G.OUT.read_text(encoding="utf-8") == G.render(G.collect()), "python tools_project/gen_enums.py"


def test_enums_cover_library_design_and_project_types() -> None:
    enums = G.collect()
    assert enums["E_MotorState"]["Fault"] == 4  # библиотека (снимок)
    assert enums["E_ControlAct"]["Float"] == 3  # DESIGN, раздел 3.1 (логика станции)
    assert enums["E_SimAiFault"]["UnderRange"] == 4  # DESIGN, раздел 3.3 (модель)
    assert enums["E_EventKind"] == {"Alarm": 1, "Station": 2}  # src/DUTs/Log
