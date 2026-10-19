"""plc210_io.py без CODESYS: каналы Modbus в PLCopenXML, план дерева устройств ПЛК210, таблица привязок в README."""

from __future__ import annotations

import json
import re
from xml.etree import ElementTree

import pytest

import plc210_io as P


def signal(**kw: object) -> P.Signal:
    base: dict[str, object] = {
        "tag": "X1",
        "description": "сигнал",
        "signal_type": "DI",
        "io_module": "",
        "io_channel": None,
        "mb_link": "",
        "mb_slave": None,
        "mb_func": None,
        "mb_reg": None,
        "mb_type": "",
        "mb_order": "",
    }
    base.update(kw)
    return P.Signal(**base)  # type: ignore[arg-type]


def test_param_ids_match_owen_example_exports() -> None:
    """Идентификаторы параметров каналов — как в выгрузке примеров ОВЕН Example_CodesysModbus*_3517v1."""
    assert P.param_id(0, P.KIND_CONFIG, 0) == 17825792
    assert P.param_id(0, P.KIND_INPUT, 4) == 21233668  # МВ110-8А: FC3 4x 4
    assert P.param_id(0, P.KIND_INPUT, 0x33) == 21233715  # МК210-301: FC3 4x 51
    assert P.param_id(1, P.KIND_CONFIG, 0) == 34603008
    assert P.param_id(1, P.KIND_OUTPUT, 0x1D6) == 42205654  # МК210-301: FC16 4x 470
    assert P.param_id(0, P.KIND_INPUT, 4000) == 21237664  # МВ210-101: FC3 4x 4000
    assert P.xml_name("21233668_0_0_0") == "_x0032_1233668_0_0_0"
    assert P.xml_name("Channel") == "Channel"


def parse_params(xml: str) -> list[ElementTree.Element]:
    return list(ElementTree.fromstring(f"<HostParameterSet>{xml}</HostParameterSet>"))


def config_elements(cfg: ElementTree.Element) -> dict[str | None, str | None]:
    value = cfg.find("Value")
    assert value is not None
    return {e.get("name"): e.text for e in value}


def test_channel_xml_read_with_word_mapping() -> None:
    ch = P.Channel(3, 100, 4, 100, "P101: FC3 4x 100…103", words={k: f"Application.PRG.aw[{k}]" for k in range(4)})
    cfg, data = parse_params(P.channel_xml(1, ch))
    assert cfg.get("ParameterId") == str(P.param_id(1, P.KIND_CONFIG, 0))
    elems = config_elements(cfg)
    assert elems["FunctionCode"] == "3"
    assert elems["ReadOffset"] == "16#0064" and elems["ReadLength"] == "4"
    assert elems["WriteOffset"] == "16#0000" and elems["WriteLength"] == "0"
    assert elems["Trigger"] == str(P.TRIGGER_CYCLIC) and elems["CycleTime"] == "100"
    assert data.get("ParameterId") == str(P.param_id(1, P.KIND_INPUT, 100))
    assert data.get("type") == "std:ARRAY[0..3] OF WORD"
    attrs = data.find("Attributes")
    assert attrs is not None and attrs.get("channel") == "input"
    words = data.findall("Value")
    assert [w.get("desc") for w in words] == ["0x0064", "0x0065", "0x0066", "0x0067"]
    assert all(len(w) == P.WORD_BITS for w in words)
    mapping = data.find("Mapping")
    assert mapping is not None
    assert (mapping[0].get("name"), mapping[0].text) == (words[0].get("name"), "Application.PRG.aw[0]")


def test_channel_xml_write_and_bit_mapping_nested() -> None:
    """Запись — канал output; привязки битов вложены в элемент слова (так выгружает CODESYS)."""
    wr = P.Channel(16, 0, 2, 100, "запись", words={0: "Application.A.w0", 1: "Application.A.w1"})
    cfg, data = parse_params(P.channel_xml(0, wr))
    elems = config_elements(cfg)
    assert elems["WriteOffset"] == "16#0000" and elems["WriteLength"] == "2" and elems["ReadLength"] == "0"
    assert data.get("ParameterId") == str(P.param_id(0, P.KIND_OUTPUT, 0))
    bits = P.Channel(3, 51, 2, 100, "маска", bits={(0, 0): "Application.GVL_IO.xA", (0, 14): "Application.GVL_IO.xB"})
    _, data = parse_params(P.channel_xml(0, bits))
    mapping = data.find("Mapping")
    assert mapping is not None and len(mapping) == 1  # только слово 0
    word = mapping[0]
    assert [(b.get("name"), b.text) for b in word] == [
        (f"{word.get('name')}_0", "Application.GVL_IO.xA"),
        (f"{word.get('name')}_14", "Application.GVL_IO.xB"),
    ]


@pytest.mark.parametrize(
    "ch",
    [
        P.Channel(5, 0, 1, 100, "FC5"),
        P.Channel(3, 0, 0, 100, "пусто"),
        P.Channel(3, 0, 126, 100, "длинный"),
        P.Channel(3, 0, 2, 100, "слово вне канала", words={2: "x"}),
        P.Channel(3, 0, 1, 100, "бит вне слова", bits={(0, 16): "x"}),
        P.Channel(3, 0, 1, 100, "слово и биты", words={0: "x"}, bits={(0, 1): "y"}),
    ],
)
def test_channel_checks(ch: P.Channel) -> None:
    with pytest.raises(P.PlanError):
        P.channel_xml(0, ch)


def test_var_names_follow_iolistgen() -> None:
    assert P.var_name(signal(tag="LS102", signal_type="DI")) == "xLS102"
    assert P.var_name(signal(tag="LT101", signal_type="AI")) == "rLT101_mA"
    assert P.var_name(signal(tag="P101_STW", signal_type="MB", mb_type="WORD")) == "wP101_STW"
    assert P.var_name(signal(tag="P101_FACT", signal_type="MB", mb_type="UINT")) == "uiP101_FACT"
    assert P.var_name(signal(tag="TT403", signal_type="MB", mb_type="REAL")) == "rTT403"
    with pytest.raises(P.PlanError):
        P.var_name(signal(signal_type="MB", mb_type="LREAL"))


@pytest.fixture(scope="module")
def plan() -> P.Plan:
    return P.load_plan()


def test_plan_covers_every_io_list_signal(plan: P.Plan) -> None:
    signals = P.parse_io_list(P.IO_LIST_FILE.read_text(encoding="utf-8"))
    io_signals = [s for s in signals if s.io_module or s.signal_type == "MB"]
    assert sorted(b.tag for b in plan.bindings) == sorted(s.tag for s in io_signals)
    assert len(plan.bindings) == 58


def test_plan_builtin_io(plan: P.Plan) -> None:
    maps = plan.job["mappings"]
    di = [m for m in maps if m["device"] == "LeftSide"]
    assert len(di) == 12 and di[0] == {
        "device": "LeftSide",
        "param": 5001,
        "element": "FDI_1",
        "variable": "Application.GVL_IO.xLS102",
    }
    do = [m for m in maps if m["param"] == 6003]
    assert [m["element"] for m in do] == [f"RDO_{n}" for n in range(1, 8)]
    ai = [m for m in maps if m["param"] in range(5701, 5705) or m["param"] in range(5801, 5805)]
    assert len(ai) == 8
    assert {
        "device": "RightSide",
        "param": 5701,
        "element": None,
        "variable": f"Application.{P.PRG_IN}.arAiValue_pct[1]",
    } in ai
    assert plan.job["parameters"] == [{"device": "RightSide", "param": 300 + n, "value": "11"} for n in range(1, 5)]


def test_plan_serial_lines(plan: P.Plan) -> None:
    lines = {line["link"]: line for line in plan.job["serial"]}
    assert lines["RS485-1"]["com_port"] == 5 and lines["RS485-2"]["com_port"] == 4
    p101 = lines["RS485-1"]["slaves"][0]
    assert (p101["name"], p101["address"]) == ("P101", 1)
    assert p101["channels"] == [
        {"function": 16, "offset": 0, "length": 2, "cycle_ms": 100, "mapped": 2},
        {"function": 3, "offset": 100, "length": 4, "cycle_ms": 100, "mapped": 4},
    ]
    assert f"Application.{P.PRG_OUT}.awP101Wr[1]" in p101["channels_xml"]
    tt = lines["RS485-2"]["slaves"][0]
    assert (tt["name"], tt["address"]) == ("TT403", 10)
    assert tt["channels"] == [{"function": 4, "offset": 0, "length": 2, "cycle_ms": 1000, "mapped": 2}]


def test_plan_mx210_modules(plan: P.Plan) -> None:
    eth = plan.job["ethernet"]
    slaves = {s["name"]: s for s in eth["slaves"]}
    assert slaves["MV210_101"]["ip"] == "[192,168,1,20]"
    assert slaves["MV210_101"]["channels"] == [
        {"function": 3, "offset": 4000, "length": 2, "cycle_ms": 100, "mapped": 2}
    ]
    di = slaves["MV210_202"]
    assert di["channels"] == [{"function": 3, "offset": 51, "length": 2, "cycle_ms": 100, "mapped": 15}]
    assert ">Application.GVL_IO.xMS133<" in di["channels_xml"]  # D2.15 = DI15 = бит 14 регистра 51


def test_plan_arrays_match_overlay_declarations(plan: P.Plan) -> None:
    """Массивы, которые привязывает дерево, объявлены в программах полевой шины с теми же границами."""
    overlay = P.ROOT / "targets" / "plc210" / "src" / "POUs" / "FieldBus"
    decl = "".join(p.read_text(encoding="utf-8") for p in overlay.rglob("*.decl.st"))
    consts = (P.ROOT / "targets" / "plc210" / "src" / "GVLs" / "GVL_ConstPlc210.gvl.st").read_text(encoding="utf-8")
    values = {m[0]: int(m[1]) for m in re.findall(r"(\w+) : INT := (\d+);", consts)}
    xml = json.dumps(plan.job)
    for prg, array, index in re.findall(r"Application\.(PRG_FieldBus\w+)\.(\w+)\[(\d+)\]", xml):
        m = re.search(rf"{array} : ARRAY\[(\w+(?:\.\w+)?)\.\.GVL_ConstPlc210\.(\w+)\]", decl)
        assert m, f"{prg}.{array} не объявлен"
        low = values[m.group(1).split(".")[-1]] if not m.group(1).isdigit() else int(m.group(1))
        assert low <= int(index) <= values[m.group(2)], f"{prg}.{array}[{index}] вне границ"


def test_plan_rejects_unknown_slave() -> None:
    hw = json.loads(P.HARDWARE_FILE.read_text(encoding="utf-8"))
    sig = signal(tag="Q", signal_type="MB", mb_link="RS485-1", mb_slave=7, mb_func=3, mb_reg=0, mb_type="WORD")
    with pytest.raises(P.PlanError, match="нет имени"):
        P.build_plan(hw, [sig])


def test_plan_rejects_gaps_and_missing_vars() -> None:
    hw = json.loads(P.HARDWARE_FILE.read_text(encoding="utf-8"))
    a = signal(tag="A", signal_type="MB", mb_link="RS485-1", mb_slave=1, mb_func=3, mb_reg=100, mb_type="WORD")
    b = signal(tag="B", signal_type="MB", mb_link="RS485-1", mb_slave=1, mb_func=3, mb_reg=102, mb_type="WORD")
    with pytest.raises(P.PlanError, match="не подряд"):
        P.build_plan(hw, [a, b])
    di = signal(tag="LS1", signal_type="DI", io_module="D1", io_channel=1)
    with pytest.raises(P.PlanError, match="нет переменных"):
        P.build_plan(hw, [di], gvl_io={"xOther"})
    with pytest.raises(P.PlanError, match="каналов 12"):
        P.build_plan(hw, [signal(tag="LS13", signal_type="DI", io_module="D1", io_channel=13)])


def test_readme_table_is_current() -> None:
    """Таблица привязок в targets/plc210/README.md совпадает с перечнем (как table --check в CI)."""
    assert P.main(["table", "--check"]) == 0


def test_replace_section_needs_markers() -> None:
    with pytest.raises(P.PlanError):
        P.replace_section("нет маркеров", "x")
    text = f"a\n{P.TABLE_BEGIN}\nold\n{P.TABLE_END}\nb\n"
    assert P.replace_section(text, "new\n") == f"a\n{P.TABLE_BEGIN}\nnew\n{P.TABLE_END}\nb\n"


def test_summarize_result() -> None:
    res = {"build": {"errors": 0, "warnings": 0}, "generate": {"errors": 0, "warnings": 1}}
    assert P.summarize_result(res) == [
        "сборка: ошибок 0, предупреждений 0",
        "генерация кода: ошибок 0, предупреждений 1",
    ]
