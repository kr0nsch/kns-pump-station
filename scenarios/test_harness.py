"""Обвязка сценариев на имитаторе OPC UA-сервера CODESYS (asyncua в процессе, без ПЛК; DESIGN 14.3)."""

from __future__ import annotations

import json
import math
from pathlib import Path

import pytest

from kns_scenarios import report
from kns_scenarios.alarms import AlarmView, load_alarm_list
from kns_scenarios.backend_opcua import OpcUaClient, OpcUaError, find_iec_namespace, node_id
from kns_scenarios.client import NotSupportedError, substitute
from kns_scenarios.context import ExpressionError, ScenarioContext, ScenarioTimeout
from kns_scenarios.credentials import CredentialsError, load_credentials
from kns_scenarios.enums import ENUMS
from kns_scenarios.journal import EventFeed, JournalGap, event_id
from kns_scenarios.scenario import FAIL, PASS, Runner, ScenarioError, load_scenario, parse_scenario
from kns_scenarios.values import LiteralError, compare, parse_literal, parse_time
from mock_plc import DEVICE, MockPlc, start_mock_plc
from plc_fixtures import client, mock_plc  # фикстуры pytest

EXAMPLES = Path(__file__).resolve().parent / "examples"
K_FAST = 50.0  # ускорение имитатора в тестах: таймауты контура проходят быстро


def context(client: OpcUaClient, k: float = K_FAST) -> ScenarioContext:
    return ScenarioContext(client, time_scale=k, poll_s=0.02, margin_s=3.0, enums=ENUMS)


# --- значения и пути ---------------------------------------------------------------------------


def test_parse_literals() -> None:
    assert parse_literal("TRUE") is True and parse_literal("false") is False
    assert parse_literal("INT#5") == 5 and parse_literal("REAL#1.5") == 1.5
    assert parse_literal("16#00FF") == 255 and parse_literal("-3") == -3 and parse_literal("2.5") == 2.5
    assert parse_literal("E_MotorState.Fault", ENUMS) == ENUMS["E_MotorState"]["Fault"]
    assert parse_literal("PL.E_CmdResult.RejectedFault", ENUMS) == ENUMS["E_CmdResult"]["RejectedFault"]
    assert parse_literal("'P101.FTS'") == "P101.FTS"
    assert parse_time("T#1M30S") == 90.0 and parse_time("LTIME#200MS") == pytest.approx(0.2)
    for bad in ("E_Nope.X", "E_MotorState.Nope", "WSTRING#x", "T#5X", "abc"):
        with pytest.raises(LiteralError):
            parse_literal(bad, ENUMS)


def test_compare_operators() -> None:
    assert compare(1.4000001, "=", 1.4) and compare(2, "<>", 3) and compare(3, ">=", 3)
    assert compare(0x0201, "&", 0x0200) and not compare(0x0001, "&", 0x0200)
    assert compare(True, "=", True) and not compare(0.5, ">", 1)
    with pytest.raises(LiteralError):
        compare(1.5, "&", 1)


def test_substitute_captures() -> None:
    assert substitute("GVL_Devices.fbP10{lead}.stSts.eState", {"lead": 2}) == "GVL_Devices.fbP102.stSts.eState"
    assert substitute("x[{n}]", {"n": 3.0}) == "x[3]"
    with pytest.raises(KeyError):
        substitute("{lead}", {})


def test_node_ids_like_codesys() -> None:
    namespaces = ["http://opcfoundation.org/UA/", "urn:x:CODESYS Control Win V3:IecVarAccess"]
    assert find_iec_namespace(namespaces) == 1
    assert (
        node_id(4, "CODESYS Control Win V3", "GVL_IO.xLS102")
        == "ns=4;s=|var|CODESYS Control Win V3.Application.GVL_IO.xLS102"
    )
    with pytest.raises(OpcUaError):
        find_iec_namespace(namespaces[:1])


def test_credentials_hide_password(tmp_path: Path) -> None:
    path = tmp_path / "credentials.json"
    path.write_text(json.dumps({"user": "cdsci", "password": "s3cret", "note": "test"}), encoding="utf-8")
    creds = load_credentials(path)
    assert creds.user == "cdsci" and "s3cret" not in repr(creds)
    with pytest.raises(CredentialsError):
        load_credentials(tmp_path / "missing.json")


# --- клиент OPC UA -------------------------------------------------------------------------------


def test_connect_discovers_namespace_and_device(client: OpcUaClient) -> None:
    assert client.device == DEVICE
    assert client.namespace >= 1


def test_read_write_typed_values(client: OpcUaClient) -> None:
    client.write({"GVL_Persist.stP101Retain.udiOpTime_s": 360000, "GVL_Sim.stSimCmd.rSetLevel_m": 1.7})
    assert client.read(["GVL_Persist.stP101Retain.udiOpTime_s", "GVL_Sim.stSimCmd.rSetLevel_m"]) == [
        360000,
        pytest.approx(1.7),
    ]
    with pytest.raises(OpcUaError):
        client.write({"GVL_Persist.stP101Retain.udiOpTime_s": 1.5})
    with pytest.raises(NotSupportedError):
        client.reset("warm")


# --- действия и ожидания -------------------------------------------------------------------------


def test_wait_in_process_time_and_timeout(client: OpcUaClient) -> None:
    ctx = context(client)
    start = ctx.mark("t0")
    ctx.wait(f"GVL_Time.lrMainNow_s > {start + 1.0}", timeout_s=30)
    assert ctx.marks["t0"] == start
    ctx.margin_s = 0.2
    with pytest.raises(ScenarioTimeout, match="последнее значение"):
        ctx.wait("GVL_Station.stStationSts.uiPumpsAvailable = 99", timeout_s=1)
    with pytest.raises(ExpressionError):
        ctx.condition("нет оператора")


def test_pulse_station_command_counts_sequence(client: OpcUaClient) -> None:
    ctx = context(client)
    before = int(ctx.read1("GVL_Station.stStationSts.uiCmdSeq"))
    ctx.pulse("GVL_Station.stStationCmd.xAckAll")
    assert ctx.read1("GVL_Station.stStationCmd.xAckAll") is False
    assert int(ctx.read1("GVL_Station.stStationSts.uiCmdSeq")) > before


def test_inject_fault_and_read_status(client: OpcUaClient) -> None:
    ctx = context(client)
    ctx.inject("axVfdFault", True, index=3)
    ctx.wait("GVL_Devices.fbP103.stSts.eState = E_MotorState.Fault", timeout_s=10)
    status = ctx.device_status("P103", extra=("eState",))
    assert status["eState"] == ENUMS["E_MotorState"]["Fault"]
    assert set(ctx.station_status()) >= {"eMode", "uiLeadPump", "wState", "rLevel_m"}
    ctx.clear_faults()
    assert ctx.read1("GVL_Sim.stFaultInj.axVfdFault[3]") is False


def test_hold_divides_by_time_scale(client: OpcUaClient) -> None:
    slept: list[float] = []
    ctx = context(client, k=20.0)
    ctx.sleep = slept.append
    ctx.hold(30.0)
    assert slept == [1.5]


def test_event_feed_reads_new_records_and_detects_gap(mock_plc: MockPlc, client: OpcUaClient) -> None:
    ctx = context(client)
    feed = EventFeed(client)
    feed.start_at_end()
    ctx.inject("axVfdFault", True, index=1)
    records = []
    for _ in range(200):  # курсор обновляется в цикле «ПЛК» после записи udiFromSeq
        records += feed.poll()
        if any(r.id == 114 for r in records):  # P101.EXT
            break
        ctx.sleep(0.02)
    assert any(r.id == 114 for r in records)
    assert [r.seq for r in records] == sorted(r.seq for r in records)
    assert all(not math.isnan(r.mono_s) for r in records)
    mock_plc.overwritten = len(mock_plc.journal) + 5  # кольцо ушло вперёд
    ctx.wait(f"GVL_Log.stEventFeed.udiSeqFirst >= {mock_plc.overwritten}", timeout_s=10)
    with pytest.raises(JournalGap):
        feed.poll()
    mock_plc.overwritten = 0
    ctx.clear_faults()
    assert event_id("KNS1.E6") == 101006


def test_alarm_state_by_code(mock_plc: MockPlc, client: OpcUaClient) -> None:
    catalog = load_alarm_list()
    assert catalog["P102.EXT"].id == 124 and catalog["KNS1.ATS"].id == 100005
    view = AlarmView(client, catalog, ENUMS)
    assert view.state("P102.EXT") == "Normal"
    ctx = context(client)
    ctx.inject("axVfdFault", True, index=2)
    ctx.wait("GVL_Devices.fbP102.stSts.eState = E_MotorState.Fault", timeout_s=10)
    state = view.state("P102.EXT")
    for _ in range(100):  # список тревог обновляется в цикле «ПЛК»
        if state == "ActiveUnack":
            break
        ctx.sleep(0.02)
        state = view.state("P102.EXT")
    assert state == "ActiveUnack"
    ctx.clear_faults()


# --- сценарий целиком ----------------------------------------------------------------------------


def test_example_scenarios_parse() -> None:
    for path in sorted(EXAMPLES.glob("PMI-*.toml")):
        scenario = load_scenario(path)
        assert scenario.id == path.stem and scenario.time_scale > 0
    with pytest.raises(ScenarioError):
        parse_scenario({"id": "PMI-99", "title": "x", "time_scale": 1, "step": [{"wiat": "x = 1"}]})


def test_runner_pmi13_end_to_end_on_mock(tmp_path: Path) -> None:
    plc = start_mock_plc()  # свой имитатор: чистые журнал и тревоги
    try:
        with OpcUaClient(plc.url, security="none") as client:
            ctx = ScenarioContext(client, poll_s=0.02, margin_s=3.0, enums=ENUMS)
            runner = Runner(ctx, "opcua", alarms=AlarmView(client, load_alarm_list(), ENUMS), feed=EventFeed(client))
            scenario = load_scenario(EXAMPLES / "PMI-13.toml")
            scenario.time_scale = K_FAST  # имитатор: быстрее, чем на стенде
            result = runner.run(scenario)
    finally:
        plc.stop()
    failed = [(c.step, c.text, c.actual, c.note) for c in result.checks if c.ok is False]
    assert result.error is None and not failed, (result.error, failed)
    assert result.verdict == PASS
    assert ctx.captures["lead"] == 2  # ведущий — Н2 (наработка 50 ч, [setup] сценария)
    js, md = report.write_reports([result], tmp_path)
    assert json.loads(js.read_text(encoding="utf-8"))["results"][0]["verdict"] == PASS
    assert "PMI-13" in md.read_text(encoding="utf-8")


def test_runner_reports_failure_and_not_checked(client: OpcUaClient) -> None:
    ctx = context(client)
    runner = Runner(ctx, "opcua")
    scenario = parse_scenario(
        {
            "id": "PMI-98",
            "title": "проверка исполнителя",
            "time_scale": K_FAST,
            "setup": {"skip_initial_state": True},
            "step": [
                {"expect": ["GVL_Station.stStationSts.uiPumpsAvailable = 2"]},
                {"reset": "warm"},
            ],
            "teardown": {"clear_faults": False},
        }
    )
    result = runner.run(scenario)
    assert result.verdict == FAIL
    assert any(c.ok is None and "cds" in c.note for c in result.checks)
    other = Runner(ctx, "cds").run(
        parse_scenario({"id": "PMI-97", "title": "x", "time_scale": 1, "backends": ["opcua"]})
    )
    assert other.verdict == "не проверялось"


def test_opcua_reset_through_resetter(mock_plc: MockPlc) -> None:
    """Шаг reset у исполнителя opcua: средство сброса (sim.py reset) вызывается, затем новый сеанс."""
    calls: list[str] = []
    c = OpcUaClient(mock_plc.url, security="none", resetter=calls.append)
    c.connect()
    try:
        first = c.client
        c.reset("cold")
        assert calls == ["cold"] and c.client is not first
        assert isinstance(c.read(["GVL_Station.stStationSts.uiPumpsAvailable"])[0], int)
        result = Runner(context(c), "opcua").run(
            parse_scenario(
                {
                    "id": "PMI-96",
                    "title": "сброс",
                    "time_scale": K_FAST,
                    "setup": {"skip_initial_state": True},
                    "step": [{"reset": "warm"}],
                    "teardown": {"clear_faults": False},
                }
            )
        )
        assert calls == ["cold", "warm"] and result.error is None
        assert result.real_s is not None and result.started
    finally:
        c.close()
