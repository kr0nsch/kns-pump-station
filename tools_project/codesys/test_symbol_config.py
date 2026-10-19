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


TYPES_XML = """<?xml version="1.0" encoding="utf-8"?>
<Symbolconfiguration xmlns="http://www.3s-software.com/schemas/Symbolconfiguration.xsd">
  <TypeList>
    <TypeUserDef name="T_ST_EventView" typeclass="Userdef" pouclass="STRUCTURE" iecname="ST_EventView">
      <UserDefElement iecname="uiPage" type="T_UINT" byteoffset="0" vartype="VAR" access="ReadWrite" />
      <UserDefElement iecname="uiPageCount" type="T_UINT" byteoffset="2" vartype="VAR" access="Read" />
      <UserDefElement iecname="astRow" type="T_ARR" byteoffset="8" vartype="VAR" access="Read" />
    </TypeUserDef>
    <TypeUserDef name="T_ST_EventFeed" typeclass="Userdef" pouclass="STRUCTURE" iecname="ST_EventFeed">
      <UserDefElement iecname="udiFromSeq" type="T_UDINT" byteoffset="0" vartype="VAR" access="ReadWrite" />
      <UserDefElement iecname="udiSeqLast" type="T_UDINT" byteoffset="8" vartype="VAR" access="Read" />
    </TypeUserDef>
    <TypeUserDef name="T_ST_EventRecord" typeclass="Userdef" pouclass="STRUCTURE" iecname="ST_EventRecord">
      <UserDefElement iecname="udiSeq" type="T_UDINT" byteoffset="0" vartype="VAR" access="Read" />
    </TypeUserDef>
    <TypeUserDef name="T_ST_MotorCmd" typeclass="Userdef" pouclass="STRUCTURE" iecname="ST_MotorCmd">
      <UserDefElement iecname="rSpeedSp_pct" type="T_REAL" byteoffset="0" vartype="VAR" access="ReadWrite" />
    </TypeUserDef>
  </TypeList>
  <NodeList />
</Symbolconfiguration>
"""


def type_rules() -> list[S.TypeRule]:
    return S.load_type_rules(json.loads(S.RULES_FILE.read_text(encoding="utf-8")))


def test_type_rules_leave_only_cursor_fields_writable() -> None:
    # страница HMI и курсор журнала: клиент пишет только номер страницы и первый нужный номер (DESIGN, раздел 13)
    tr = type_rules()
    assert S.member_access(tr, "ST_EventView", "uiPage") == "ReadWrite"
    for member in ("uiPageCount", "uiCount", "wReserve", "astRow"):
        assert S.member_access(tr, "ST_EventView", member) == "Read", member
    assert S.member_access(tr, "ST_EventFeed", "udiFromSeq") == "ReadWrite"
    for member in ("udiSeqFirst", "udiSeqLast", "uiCount", "wReserve", "astRow"):
        assert S.member_access(tr, "ST_EventFeed", member) == "Read", member
    assert S.member_access(tr, "ST_EventRecord", "udiSeq") == "Read"  # строки журнала — только чтение
    assert S.member_access(tr, "ST_MotorCmd", "rSpeedSp_pct") is None  # без правила — права переменной


def test_parse_and_verify_type_members() -> None:
    types = S.parse_type_members(TYPES_XML)
    assert types["ST_EventView"] == {"uiPage": "ReadWrite", "uiPageCount": "Read", "astRow": "Read"}
    assert S.verify_types(types, type_rules()) == []
    tampered = {**types, "ST_EventFeed": {**types["ST_EventFeed"], "udiSeqLast": "ReadWrite"}}
    assert S.verify_types(tampered, type_rules()) == [
        "ST_EventFeed.udiSeqLast: в файле символов ReadWrite, по правилам Read"
    ]
    missing = {k: v for k, v in types.items() if k != "ST_EventView"}
    assert S.verify_types(missing, type_rules()) == ["ST_EventView: тип не выгружен в файл символов"]


def test_job_carries_variable_and_type_rules() -> None:
    job = S.make_job(S.ROOT / "build" / "kns.project", rules("sim"), type_rules())
    assert {"gvl": "GVL_IO", "vars": ["*"], "access": "Read"} in job["rules"]
    assert {"type": "ST_EventFeed", "members": [["udiFromSeq", "ReadWrite"], ["*", "Read"]]} in job["types"]


@pytest.mark.parametrize(
    "types",
    [
        [{"type": "ST_X", "members": []}],
        [{"type": "", "members": [["*", "Read"]]}],
        [{"type": "ST_X", "members": [["*", "Write"]]}],
        [{"type": "ST_X", "members": [["*"]]}],
    ],
)
def test_invalid_type_rules_rejected(types: list[dict[str, object]]) -> None:
    with pytest.raises(S.RulesError):
        S.load_type_rules({"builds": ["sim"], "rules": [], "types": types})


def test_symbol_file_name() -> None:
    project = S.ROOT / "build" / "kns.project"
    assert S.symbol_file(project, "Device").name == "kns.Device.Application.xml"
