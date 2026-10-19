"""Правила символьной конфигурации OPC UA (DESIGN, раздел 13) и сверка файла символов — без CODESYS."""

from __future__ import annotations

import json

import pytest

import symbol_config as S

SAMPLE_XML = """\ufeff<?xml version="1.0" encoding="utf-8"?>
<Symbolconfiguration xmlns="http://www.3s-software.com/schemas/Symbolconfiguration.xsd">
  <TypeList><TypeSimple name="T_BOOL" size="1" /></TypeList>
  <NodeList>
    <Node name="Application">
      <Node name="GVL_IO">
        <Node name="xLS102" type="T_BOOL" access="Read" />
      </Node>
      <Node name="GVL_Persist">
        <Node name="stLT101Cfg" type="T_ST_AnalogInputCfg" access="ReadWrite" />
      </Node>
      <Node name="GVL_Sim">
        <Node name="stSimCmd" type="T_ST_SimCmd" access="ReadWrite" />
      </Node>
    </Node>
  </NodeList>
</Symbolconfiguration>
"""


def rules(build: str) -> list[S.Rule]:
    return S.load_rules(json.loads(S.RULES_FILE.read_text(encoding="utf-8")), build)


def test_rules_file_matches_design_table_sim() -> None:
    sim = rules("sim")
    assert S.access_for(sim, "GVL_Devices", "fbP101") == "Read"
    assert S.access_for(sim, "GVL_Hmi", "stP101Cmd") == "ReadWrite"
    assert S.access_for(sim, "GVL_Hmi", "xApplyProjectCfg") == "ReadWrite"
    assert S.access_for(sim, "GVL_IO", "uiP101_FCODE") == "Read"
    assert S.access_for(sim, "GVL_Station", "stStationCmd") == "ReadWrite"
    assert S.access_for(sim, "GVL_Station", "fbLIC101") == "Read"
    assert S.access_for(sim, "GVL_Log", "stEventFeed") == "ReadWrite"
    assert S.access_for(sim, "GVL_Log", "stAlarmView") == "Read"
    assert S.access_for(sim, "GVL_Persist", "stStationCfg") == "ReadWrite"
    assert S.access_for(sim, "GVL_Persist", "stP101Retain") == "ReadWrite"
    assert S.access_for(sim, "GVL_Sim", "stFaultInj") == "ReadWrite"
    assert S.access_for(sim, "GVL_Sim", "stSimSts") == "Read"
    assert S.access_for(sim, "GVL_Time", "lrMainNow_s") == "Read"


def test_site_build_closes_writes_to_persist_and_simulation() -> None:
    site = rules("site")
    assert S.access_for(site, "GVL_Persist", "stStationCfg") == "Read"
    assert S.access_for(site, "GVL_Persist", "stP101Retain") == "Read"
    assert S.access_for(site, "GVL_Sim", "stFaultInj") is None
    assert S.access_for(site, "GVL_Sim", "xSimulation") == "Read"


def test_not_exported_without_rule() -> None:
    sim = rules("sim")
    for gvl, var in [
        ("GVL_Const", "LOG_CAPACITY"),
        ("GVL_DeviceList", "aitfDevice"),
        ("GVL_Persist", "uiLayoutVersion"),
        ("GVL_Log", "fbEventLog"),
        ("GVL_Time", "fbClockMain"),
        ("PRG_FieldIn", "fbVfdP101"),
    ]:
        assert S.access_for(sim, gvl, var) is None, f"{gvl}.{var}"


def test_names_match_case_insensitive_like_codesys() -> None:
    assert S.access_for(rules("sim"), "gvl_io", "XLS102") == "Read"


def test_first_matching_rule_wins() -> None:
    data = {
        "builds": ["sim"],
        "rules": [{"gvl": "G", "vars": ["a*"], "access": "Read"}, {"gvl": "G", "vars": ["*"], "access": "ReadWrite"}],
    }
    loaded = S.load_rules(data, "sim")
    assert S.access_for(loaded, "G", "abc") == "Read"
    assert S.access_for(loaded, "G", "xyz") == "ReadWrite"


@pytest.mark.parametrize(
    ("data", "build"),
    [
        ({"builds": ["sim"], "rules": []}, "site"),
        ({"builds": ["sim"], "rules": [{"gvl": "G", "vars": ["*"], "access": "Write"}]}, "sim"),
        ({"builds": ["sim"], "rules": [{"gvl": "G", "vars": [], "access": "Read"}]}, "sim"),
        ({"builds": ["sim"], "rules": [{"gvl": "G", "vars": ["*"], "access": {"lab": "Read"}}]}, "sim"),
    ],
)
def test_invalid_rules_rejected(data: dict[str, object], build: str) -> None:
    with pytest.raises(S.RulesError):
        S.load_rules(data, build)


def test_parse_and_verify_symbol_file() -> None:
    symbols = S.parse_symbols(SAMPLE_XML.lstrip("\ufeff"))
    assert symbols == {
        "GVL_IO": {"xLS102": "Read"},
        "GVL_Persist": {"stLT101Cfg": "ReadWrite"},
        "GVL_Sim": {"stSimCmd": "ReadWrite"},
    }
    assert S.verify(symbols, rules("sim")) == []
    problems = S.verify(symbols, rules("site"))
    assert len(problems) == 2  # на объекте Cfg — только чтение, команды модели не выгружаются
    assert S.counts(symbols)["GVL_Persist"] == {"ReadWrite": 1}


def test_symbol_file_name() -> None:
    project = S.ROOT / "build" / "kns.project"
    assert S.symbol_file(project, "Device").name == "kns.Device.Application.xml"
