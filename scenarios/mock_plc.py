"""Имитатор OPC UA-сервера CODESYS для тестов обвязки сценариев (asyncua в процессе, без ПЛК).

Узлы — как у сервера CODESYS: пространство имён ``…:IecVarAccess``, устройство в ``Objects/DeviceSet``,
строковые узлы ``|var|<устройство>.Application.<путь>`` нужных типов. Поток «ПЛК» каждые 20 мс ведёт время
процесса ``lrMainNow_s`` (с ускорением ``rTimeScale``), сбрасывает импульсы команд, считает ``uiCmdSeq`` и
грубо повторяет реакцию станции на аварию ПЧ (PMI-13): отказ насоса, код аварии 11, тревоги
``P10n.EXT`` и ``KNS1.ATS`` в ``stAlarmView``, записи в журнале и курсоре ``stEventFeed``, смена ведущего,
отказ сброса при действующей аварии. Это тестовая подставка исполнителя, а не модель объекта.
"""

from __future__ import annotations

import socket
import threading
import time
from dataclasses import dataclass, field
from typing import Any

from asyncua import ua
from asyncua.sync import Server, SyncNode

DEVICE = "CODESYS Control Win V3"
NS_URI = "urn:mock-plc:CODESYS Control Win V3:IecVarAccess"
CYCLE_S = 0.02
PUMPS = 3
FEED_ROWS = 32
VIEW_ROWS = 50
FCODE_EXT = 11
ACTIVE_UNACK = 1
MOTOR_FAULT = 4
MOTOR_RUNNING = 2
REJECTED_FAULT = 6
ACCEPTED = 1
ATS_ID = 100005
V = ua.VariantType

STATION_PULSES = ("xSetAuto", "xSetManual", "xSetStepped", "xSetLevelPid", "xAckAll", "xResetAll", "xSilence")
SIM_PULSES = ("xResetPlant", "xClearFaults", "xSetLevel")
FAULT_ARRAYS = ("axVfdFault", "axNoFeedback", "axVfdCommLoss", "axLocal")
RECORD_TYPES = (
    ("udiSeq", V.UInt32),
    ("eKind", V.Int16),
    ("ePriority", V.Int16),
    ("udiId", V.UInt32),
    ("eOldState", V.Int16),
    ("eNewState", V.Int16),
    ("eReason", V.Int16),
    ("rValue", V.Float),
    ("uliUtc_ms", V.UInt64),
    ("lrMono_s", V.Double),
)


# пути, которые пишет клиент: «ПЛК» их сбрасывает и не кэширует последнее записанное значение
CLIENT_PATHS = frozenset(
    [f"GVL_Station.stStationCmd.{n}" for n in STATION_PULSES]
    + [f"GVL_Sim.stSimCmd.{n}" for n in SIM_PULSES]
    + [f"GVL_Hmi.stP10{i}Cmd.stCommon.{n}" for i in range(1, PUMPS + 1) for n in ("xSetAuto", "xReset")]
    + ["GVL_Hmi.xApplyProjectCfg", "GVL_Log.stEventFeed.udiFromSeq", "GVL_Sim.stSimCfg.rTimeScale"]
    + [f"GVL_Sim.stFaultInj.{a}[{i}]" for a in FAULT_ARRAYS for i in range(1, PUMPS + 1)]
)


def free_port() -> int:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(("127.0.0.1", 0))
        return int(s.getsockname()[1])


def variables() -> dict[str, tuple[Any, ua.VariantType]]:
    """Путь → (начальное значение, тип OPC UA)."""
    v: dict[str, tuple[Any, ua.VariantType]] = {
        "GVL_Time.lrMainNow_s": (3600.0, V.Double),
        "GVL_Sim.stSimCfg.rTimeScale": (1.0, V.Float),
        "GVL_Sim.stSimCmd.rSetLevel_m": (0.0, V.Float),
        "GVL_Sim.stSimCmd.xInflowOverride": (False, V.Boolean),
        "GVL_Sim.stSimCmd.rInflowOverride_m3h": (0.0, V.Float),
        "GVL_Hmi.xApplyProjectCfg": (False, V.Boolean),
        "GVL_Station.stStationSts.uiCmdSeq": (0, V.UInt16),
        "GVL_Station.stStationSts.eMode": (2, V.Int16),
        "GVL_Station.stStationSts.eMethod": (1, V.Int16),
        "GVL_Station.stStationSts.eControlAct": (0, V.Int16),
        "GVL_Station.stStationSts.eNe107": (0, V.Int16),
        "GVL_Station.stStationSts.wState": (0, V.UInt16),
        "GVL_Station.stStationSts.wCfgErr": (0, V.UInt16),
        "GVL_Station.stStationSts.uiPumpsRequired": (0, V.UInt16),
        "GVL_Station.stStationSts.uiPumpsRunning": (0, V.UInt16),
        "GVL_Station.stStationSts.uiPumpsAvailable": (PUMPS, V.UInt16),
        "GVL_Station.stStationSts.uiLeadPump": (0, V.UInt16),
        "GVL_Station.stStationSts.wAlmActive": (0, V.UInt16),
        "GVL_Station.stStationSts.wAlmUnack": (0, V.UInt16),
        "GVL_Station.stStationSts.ePrioUnack": (0, V.Int16),
        "GVL_Station.stStationSts.rLevel_m": (1.2, V.Float),
        "GVL_Station.stStationSts.rLevelSp_m": (1.4, V.Float),
        "GVL_Station.stStationSts.rSpeedSp_pct": (0.0, V.Float),
        "GVL_Station.stStationSts.udiEventSeq": (0, V.UInt32),
        "GVL_Log.stEventFeed.udiFromSeq": (0, V.UInt32),
        "GVL_Log.stEventFeed.udiSeqFirst": (1, V.UInt32),
        "GVL_Log.stEventFeed.udiSeqLast": (0, V.UInt32),
        "GVL_Log.stEventFeed.uiCount": (0, V.UInt16),
        "GVL_Log.stAlarmView.uiCount": (0, V.UInt16),
        "GVL_Log.stAlarmView.uiActiveTotal": (0, V.UInt16),
    }
    for name in STATION_PULSES:
        v[f"GVL_Station.stStationCmd.{name}"] = (False, V.Boolean)
    for name in SIM_PULSES:
        v[f"GVL_Sim.stSimCmd.{name}"] = (False, V.Boolean)
    for n in range(1, PUMPS + 1):
        for arr in FAULT_ARRAYS:
            v[f"GVL_Sim.stFaultInj.{arr}[{n}]"] = (False, V.Boolean)
        v[f"GVL_Hmi.stP10{n}Cmd.stCommon.xSetAuto"] = (False, V.Boolean)
        v[f"GVL_Hmi.stP10{n}Cmd.stCommon.xReset"] = (False, V.Boolean)
        v[f"GVL_Persist.stP10{n}Retain.udiOpTime_s"] = (0, V.UInt32)
        v[f"GVL_IO.uiP10{n}_FCODE"] = (0, V.UInt16)
        base = f"GVL_Devices.fbP10{n}.stSts"
        for name, typ in (
            ("eMode", V.Int16),
            ("eNe107", V.Int16),
            ("eCmdResult", V.Int16),
            ("uiCmdSeq", V.UInt16),
            ("wStatus", V.UInt16),
            ("wFault", V.UInt16),
            ("wWarning", V.UInt16),
            ("wAlmActive", V.UInt16),
            ("wAlmUnack", V.UInt16),
        ):
            v[f"{base}.stCommon.{name}"] = (2 if name == "eMode" else 0, typ)
        v[f"{base}.eState"] = (0, V.Int16)
    for row in range(1, FEED_ROWS + 1):
        for name, typ in RECORD_TYPES:
            v[f"GVL_Log.stEventFeed.astRow[{row}].{name}"] = (0, typ)
    for row in range(1, VIEW_ROWS + 1):
        v[f"GVL_Log.stAlarmView.astRow[{row}].udiId"] = (0, V.UInt32)
        v[f"GVL_Log.stAlarmView.astRow[{row}].eState"] = (0, V.Int16)
    return v


@dataclass
class MockPlc:
    """Сервер и поток «ПЛК»; ``url`` — адрес для клиента."""

    url: str
    server: Server
    nodes: dict[str, SyncNode]
    journal: list[tuple[int, int, int, float]] = field(default_factory=list)  # (номер, id, новое состояние, время)
    alarms: dict[int, int] = field(default_factory=dict)  # id → состояние
    overwritten: int = 0  # затёрто записей (тест пропуска)
    stop_event: threading.Event = field(default_factory=threading.Event)
    thread: threading.Thread | None = None

    types: dict[str, ua.VariantType] = field(default_factory=dict)
    written: dict[str, Any] = field(default_factory=dict)  # последнее записанное «ПЛК»

    def get(self, path: str) -> Any:
        return self.nodes[path].read_value()

    def set(self, path: str, value: Any) -> None:
        """Запись «ПЛК»; значение, которое «ПЛК» уже писал, не повторяется (быстрее цикл)."""
        if self.written.get(path, object()) == value and path not in self.client_written:
            return
        self.nodes[path].write_value(ua.DataValue(ua.Variant(value, self.types[path])))
        self.written[path] = value

    @property
    def client_written(self) -> frozenset[str]:
        """Пути, которые пишет клиент (их «ПЛК» не кэширует)."""
        return CLIENT_PATHS

    def log(self, alarm_id: int, new_state: int) -> None:
        self.journal.append((len(self.journal) + 1, alarm_id, new_state, float(self.get("GVL_Time.lrMainNow_s"))))

    def raise_alarm(self, alarm_id: int) -> None:
        if self.alarms.get(alarm_id) != ACTIVE_UNACK:
            self.alarms[alarm_id] = ACTIVE_UNACK
            self.log(alarm_id, ACTIVE_UNACK)

    # --- цикл «ПЛК» ------------------------------------------------------------------------------

    def cycle(self) -> None:
        k = float(self.get("GVL_Sim.stSimCfg.rTimeScale"))
        self.set("GVL_Time.lrMainNow_s", float(self.get("GVL_Time.lrMainNow_s")) + CYCLE_S * max(k, 1.0))
        seq = int(self.get("GVL_Station.stStationSts.uiCmdSeq"))
        for name in STATION_PULSES:
            path = f"GVL_Station.stStationCmd.{name}"
            if self.get(path):
                seq += 1
                if name == "xSetAuto":
                    self.set("GVL_Station.stStationSts.eMode", 1)
                elif name in ("xSetStepped", "xSetLevelPid"):
                    # способ выбран — ведущий с наименьшей наработкой в работе (04 §5.2, грубо)
                    self.set("GVL_Station.stStationSts.eMethod", 1 if name == "xSetStepped" else 2)
                    hours = [int(self.get(f"GVL_Persist.stP10{n}Retain.udiOpTime_s")) for n in range(1, PUMPS + 1)]
                    lead = hours.index(min(hours)) + 1
                    self.set("GVL_Station.stStationSts.uiLeadPump", lead)
                    self.set("GVL_Station.stStationSts.uiPumpsRunning", 1)
                    self.set(f"GVL_Devices.fbP10{lead}.stSts.eState", MOTOR_RUNNING)
                self.set(path, False)
        self.set("GVL_Station.stStationSts.uiCmdSeq", seq)
        for name in SIM_PULSES:
            path = f"GVL_Sim.stSimCmd.{name}"
            if self.get(path):
                if name == "xClearFaults":  # сначала действие, затем сброс импульса (как модель ПЛК)
                    for n in range(1, PUMPS + 1):
                        for arr in FAULT_ARRAYS:
                            self.set(f"GVL_Sim.stFaultInj.{arr}[{n}]", False)
                self.set(path, False)
        if self.get("GVL_Hmi.xApplyProjectCfg"):
            self.set("GVL_Hmi.xApplyProjectCfg", False)
        for n in range(1, PUMPS + 1):
            self.pump(n)
        self.fill_view()
        self.fill_feed()

    def pump(self, n: int) -> None:
        base = f"GVL_Devices.fbP10{n}.stSts"
        cmd = f"GVL_Hmi.stP10{n}Cmd.stCommon"
        if self.get(f"{cmd}.xSetAuto"):
            self.set(f"{base}.stCommon.eMode", 1)
            self.set(f"{cmd}.xSetAuto", False)
        fault = bool(self.get(f"GVL_Sim.stFaultInj.axVfdFault[{n}]"))
        if fault and int(self.get(f"{base}.eState")) != MOTOR_FAULT:
            self.set(f"{base}.eState", MOTOR_FAULT)
            self.set(f"GVL_IO.uiP10{n}_FCODE", FCODE_EXT)
            self.raise_alarm((10 + n) * 10 + 4)  # P10n.EXT: dev_no · 10 + слот 4
            if int(self.get("GVL_Station.stStationSts.uiLeadPump")) == n:
                self.set("GVL_Station.stStationSts.uiLeadPump", n % PUMPS + 1)
                self.raise_alarm(ATS_ID)
        if self.get(f"{cmd}.xReset"):
            if fault:
                self.set(f"{base}.stCommon.eCmdResult", REJECTED_FAULT)
            else:
                self.set(f"{base}.stCommon.eCmdResult", ACCEPTED)
                self.set(f"{base}.eState", 0)
            self.set(f"{cmd}.xReset", False)

    def fill_view(self) -> None:
        rows = sorted(self.alarms.items())
        for i in range(1, VIEW_ROWS + 1):
            alarm_id, state = rows[i - 1] if i <= len(rows) else (0, 0)
            self.set(f"GVL_Log.stAlarmView.astRow[{i}].udiId", alarm_id)
            self.set(f"GVL_Log.stAlarmView.astRow[{i}].eState", state)
        self.set("GVL_Log.stAlarmView.uiCount", min(len(rows), VIEW_ROWS))
        self.set("GVL_Log.stAlarmView.uiActiveTotal", len(rows))

    def fill_feed(self) -> None:
        last = len(self.journal)
        first = max(1, self.overwritten + 1, last + 1 - 200)
        start = max(int(self.get("GVL_Log.stEventFeed.udiFromSeq")), first)
        self.set("GVL_Log.stEventFeed.udiSeqFirst", first)
        self.set("GVL_Log.stEventFeed.udiSeqLast", last)
        count = 0
        for row in range(1, FEED_ROWS + 1):
            seq = start + row - 1
            rec = self.journal[seq - 1] if seq <= last else None
            values = (rec[0], 1, 2, rec[1], 0, rec[2], 1, 0.0, 0, rec[3]) if rec else (0,) * 7 + (0.0, 0, 0.0)
            for (name, _typ), value in zip(RECORD_TYPES, values, strict=True):
                self.set(f"GVL_Log.stEventFeed.astRow[{row}].{name}", value)
            count += 1 if rec else 0
        self.set("GVL_Log.stEventFeed.uiCount", count)

    def run(self) -> None:
        while not self.stop_event.is_set():
            started = time.monotonic()
            self.cycle()
            self.stop_event.wait(max(0.0, CYCLE_S - (time.monotonic() - started)))

    def stop(self) -> None:
        self.stop_event.set()
        if self.thread is not None:
            self.thread.join(timeout=5)
        self.server.stop()


def string_node(identifier: str, ns: int) -> ua.NodeId:
    """Строковый узел ``ns=<ns>;s=<identifier>``."""
    return ua.NodeId.from_string(f"ns={ns};s={identifier}")


def start_mock_plc() -> MockPlc:
    """Запустить сервер (анонимный вход, без шифрования) и поток «ПЛК»."""
    url = f"opc.tcp://127.0.0.1:{free_port()}/mock/"
    server = Server()
    server.set_endpoint(url)
    server.set_security_policy([ua.SecurityPolicyType.NoSecurity])
    ns = server.register_namespace(NS_URI)
    objects = server.nodes.objects
    device_set = objects.add_folder(string_node("DeviceSet", ns), ua.QualifiedName("DeviceSet", ns))
    device_set.add_object(string_node(DEVICE, ns), ua.QualifiedName(DEVICE, ns))
    app = objects.add_folder(string_node("Application", ns), ua.QualifiedName("Application", ns))
    nodes: dict[str, SyncNode] = {}
    for path, (value, typ) in variables().items():
        node = app.add_variable(
            string_node(f"|var|{DEVICE}.Application.{path}", ns), ua.QualifiedName(path, ns), ua.Variant(value, typ)
        )
        node.set_writable()
        nodes[path] = node
    server.start()
    plc = MockPlc(url, server, nodes, types={p: t for p, (_v, t) in variables().items()})
    plc.thread = threading.Thread(target=plc.run, name="mock-plc", daemon=True)
    plc.thread.start()
    return plc
