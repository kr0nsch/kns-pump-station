#!/usr/bin/env python3
"""Дерево устройств сборки ОВЕН ПЛК210 (targets/plc210) из перечня сигналов и ``targets/plc210/hardware.json``.

Что строится (docs/DESIGN.md, раздел 8.4; targets/plc210/README.md):

- модуль-слот модификации ПЛК210 (``slot``), встроенные DI и релейные DO — привязка битов каналов к ``GVL_IO``,
  встроенные AI — тип датчика «4-20 mA» и привязка «Значения» и «Статуса» к массивам ``PRG_FieldBusIn_Plc210``;
- линии RS-485: «Modbus COM» (номер COM-порта ПЛК210), «Modbus Master, COM Port», слейвы с каналами FC16/FC3/FC4
  по ``docs/03_io_list.csv`` (колонки ``mb_*``), данные — в массивы ``PRG_FieldBusIn_Plc210`` и
  ``PRG_FieldBusOut_Plc210``;
- Ethernet и «Modbus TCP Master» с модулями ОВЕН Mx210: МВ210-101 (вход 1 — в массив, ток считает
  ``F_Mx210AiToMa``), МВ210-202 (биты маски входов — прямо в ``GVL_IO``).

Каналы слейвов Modbus скриптовый API CODESYS 3.5.17 не создаёт: скрипт CODESYS выгружает слейв в PLCopenXML,
вставляет параметры каналов, которые готовит этот модуль (``channels_xml``), и импортирует слейв обратно. Формат
параметров (идентификаторы ``(канал + 1) << 24 | вид << 16 | смещение``, ``CHANNEL_PACKED``, привязки) снят с
выгрузки примеров ОВЕН ``Example_CodesysModbus*_3517v1`` и проверен сборкой.

Команды::

    python tools_project/codesys/plc210_io.py table [--write | --check]   таблица привязок в targets/plc210/README.md
    python tools_project/codesys/plc210_io.py apply --project PATH       дерево устройств, сборка, генерация кода

``apply`` вызывает ``tools_project/targets.py build plc210`` после ``cds.py import``; вручную — для готового проекта.
Коды выхода: 0 — успех, 1 — ошибки сборки или таблица устарела, 2 — неверные данные, 3 и выше — как у ``cds.py``.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from collections.abc import Iterable, Mapping, Sequence
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
TOOLS_CODESYS = ROOT / "tools" / "codesys"
if str(TOOLS_CODESYS) not in sys.path:
    sys.path[:0] = [str(TOOLS_CODESYS)]

from cdshost import cli  # noqa: E402

HERE = Path(__file__).resolve().parent
TARGET_DIR = ROOT / "targets" / "plc210"
HARDWARE_FILE = TARGET_DIR / "hardware.json"
README_FILE = TARGET_DIR / "README.md"
IO_LIST_FILE = ROOT / "docs" / "03_io_list.csv"
GVL_IO_FILE = ROOT / "src" / "GVLs" / "Generated" / "GVL_IO.gvl.st"
SCRIPT = HERE / "plc210_io_cds.py"
EXIT_USAGE = 2

APP = "Application"
PRG_IN = "PRG_FieldBusIn_Plc210"
PRG_OUT = "PRG_FieldBusOut_Plc210"
TABLE_BEGIN = "<!-- plc210_io:table:begin (раздел пишет `python tools_project/codesys/plc210_io.py table --write`) -->"
TABLE_END = "<!-- plc210_io:table:end -->"

# Каналы Modbus Slave IoDrvModbus 3.5.17 (выгрузка примеров ОВЕН)
KIND_CONFIG = 0x10
KIND_INPUT = 0x44
KIND_OUTPUT = 0x84
TRIGGER_CYCLIC = 5
READ_FUNCTIONS = (3, 4)
WRITE_FUNCTIONS = (16,)
WORD_BITS = 16
MAX_REGISTERS = 125
VAR_PREFIX = {"WORD": "w", "UINT": "ui", "REAL": "r", "INT": "i", "DWORD": "dw"}
FUNCTION_NAMES = {3: "Read Holding Registers", 4: "Read Input Registers", 16: "Write Multiple Registers"}
FUNCTION_SHORT = {3: "FC3 4x", 4: "FC4 3x", 16: "FC16 4x"}


class PlanError(Exception):
    """Перечень сигналов не ложится на состав ПЛК210 (hardware.json)."""


# ---------------------------------------------------------------------------
# Перечень сигналов
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Signal:
    """Строка перечня сигналов (только колонки, нужные дереву устройств)."""

    tag: str
    description: str
    signal_type: str
    io_module: str
    io_channel: int | None
    mb_link: str
    mb_slave: int | None
    mb_func: int | None
    mb_reg: int | None
    mb_type: str
    mb_order: str

    @property
    def io_ref(self) -> str:
        return f"{self.io_module}.{self.io_channel}" if self.io_module else ""


def _int(text: str) -> int | None:
    text = text.strip()
    return int(text) if text else None


def parse_io_list(text: str) -> list[Signal]:
    """Строки перечня сигналов (CSV с разделителем «;», первая строка — заголовок)."""
    rows = csv.DictReader(text.splitlines(), delimiter=";")
    signals: list[Signal] = []
    for row in rows:
        signals.append(
            Signal(
                tag=row["tag"].strip(),
                description=row["description"].strip(),
                signal_type=row["signal_type"].strip(),
                io_module=row["io_module"].strip(),
                io_channel=_int(row["io_channel"]),
                mb_link=row["mb_link"].strip(),
                mb_slave=_int(row["mb_slave"]),
                mb_func=_int(row["mb_func"]),
                mb_reg=_int(row["mb_reg"]),
                mb_type=row["mb_type"].strip(),
                mb_order=row["mb_order"].strip(),
            )
        )
    return signals


def var_name(sig: Signal) -> str:
    """Имя переменной сигнала в GVL_IO по правилам iolistgen: x — DI/DO, r…_mA — AI, префикс типа — Modbus."""
    if sig.signal_type in ("DI", "DO"):
        return "x" + sig.tag
    if sig.signal_type == "AI":
        return "r" + sig.tag + "_mA"
    if sig.signal_type == "MB":
        if sig.mb_type not in VAR_PREFIX:
            raise PlanError(f"{sig.tag}: тип регистра {sig.mb_type!r} не поддерживается")
        return VAR_PREFIX[sig.mb_type] + sig.tag
    raise PlanError(f"{sig.tag}: тип сигнала {sig.signal_type!r} не поддерживается")


_VAR_DECL_RE = re.compile(r"^\s*([A-Za-z_][A-Za-z0-9_]*)\s*:", re.MULTILINE)


def gvl_names(text: str) -> set[str]:
    """Имена переменных списка глобальных переменных (для сверки с перечнем)."""
    return set(_VAR_DECL_RE.findall(text))


# ---------------------------------------------------------------------------
# Каналы Modbus в PLCopenXML
# ---------------------------------------------------------------------------


def param_id(channel: int, kind: int, low: int) -> int:
    """Идентификатор параметра канала: (номер канала + 1) << 24 | вид << 16 | смещение."""
    return ((channel + 1) << 24) | (kind << 16) | low


def xml_name(text: str) -> str:
    """Имя элемента XML, как его пишет CODESYS (XmlConvert.EncodeName): ведущая цифра — _xHHHH_."""
    if text and text[0].isdigit():
        return f"_x{ord(text[0]):04X}_{text[1:]}"
    return text


def _esc(text: str) -> str:
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")


@dataclass
class Channel:
    """Канал Modbus слейва: функция, первый регистр, длина, период; привязки слов и битов к переменным."""

    function: int
    offset: int
    length: int
    cycle_ms: int
    comment: str
    words: dict[int, str] = field(default_factory=dict)  # индекс слова -> переменная
    bits: dict[tuple[int, int], str] = field(default_factory=dict)  # (слово, бит) -> переменная

    def check(self, index: int) -> None:
        if self.function not in READ_FUNCTIONS + WRITE_FUNCTIONS:
            raise PlanError(f"канал {index}: функция Modbus {self.function} не поддерживается")
        if not 1 <= self.length <= MAX_REGISTERS or not 0 <= self.offset <= 0xFFFF:
            raise PlanError(f"канал {index}: регистр {self.offset}, длина {self.length} вне диапазона")
        for word in self.words:
            if not 0 <= word < self.length:
                raise PlanError(f"канал {index}: слово {word} вне канала длиной {self.length}")
        for word, bit in self.bits:
            if not 0 <= word < self.length or not 0 <= bit < WORD_BITS:
                raise PlanError(f"канал {index}: бит {word}.{bit} вне канала")
            if word in self.words:
                raise PlanError(f"канал {index}: слово {word} привязано целиком и по битам")

    @property
    def is_read(self) -> bool:
        return self.function in READ_FUNCTIONS


def channel_xml(index: int, ch: Channel) -> str:
    """XML параметров канала: настройка (CHANNEL_PACKED) и данные с привязками к переменным."""
    ch.check(index)
    cfg_id = param_id(index, KIND_CONFIG, 0)
    read_offset, read_len = (ch.offset, ch.length) if ch.is_read else (0, 0)
    write_offset, write_len = (0, 0) if ch.is_read else (ch.offset, ch.length)
    out = [
        f'<Parameter ParameterId="{cfg_id}" type="localTypes:CHANNEL_PACKED"><Attributes />',
        f'<Value name="{xml_name(str(cfg_id))}" visiblename="Channel {index}" desc="ChannelConfig">',
        f'<Element name="FunctionCode" visiblename="Function Code">{ch.function}</Element>',
        f'<Element name="ReadOffset" visiblename="Read Offset">16#{read_offset:04X}</Element>',
        f'<Element name="ReadLength" visiblename="Read Length">{read_len}</Element>',
        f'<Element name="WriteOffset" visiblename="Write Offset">16#{write_offset:04X}</Element>',
        f'<Element name="WriteLength" visiblename="Write Length">{write_len}</Element>',
        f'<Element name="Trigger" visiblename="Trigger">{TRIGGER_CYCLIC}</Element>',
        f'<Element name="CycleTime" visiblename="Cycle Time">{ch.cycle_ms}</Element>',
        '<Element name="ErrorHandling" visiblename="Error Handling">true</Element>',
        '<Element name="EnableRegisterBitMapping" visiblename="EnableRegisterBitMapping" />',
        f"</Value><Name>Channel {index}</Name><Description>{_esc(ch.comment)}</Description></Parameter>",
    ]
    data_id = param_id(index, KIND_INPUT if ch.is_read else KIND_OUTPUT, ch.offset)
    out.append(f'<Parameter ParameterId="{data_id}" type="std:ARRAY[0..{ch.length - 1}] OF WORD">')
    out.append(f'<Attributes channel="{"input" if ch.is_read else "output"}" />')
    names = [xml_name(f"{data_id}_{k}_0_0") for k in range(ch.length)]
    for k, name in enumerate(names):
        out.append(f'<Value name="{name}" visiblename="Channel {index}[{k}]" desc="0x{ch.offset + k:04X}">')
        out.extend(f'<Element name="{name}_{b}" visiblename="Bit{b}">FALSE</Element>' for b in range(WORD_BITS))
        out.append("</Value>")
    out.append(f"<Name>Channel {index}</Name><Description>{FUNCTION_NAMES[ch.function]}</Description>")
    if ch.words or ch.bits:
        # привязка слова — элемент слова; привязки битов — элементы бит внутри элемента слова (так выгружает CODESYS)
        out.append("<Mapping>")
        for k, name in enumerate(names):
            if k in ch.words:
                out.append(f'<Element name="{name}">{_esc(ch.words[k])}</Element>')
                continue
            bits = sorted((b, var) for (w, b), var in ch.bits.items() if w == k)
            if bits:
                out.append(f'<Element name="{name}">')
                out.extend(f'<Element name="{name}_{b}">{_esc(var)}</Element>' for b, var in bits)
                out.append("</Element>")
        out.append("</Mapping>")
    out.append("</Parameter>")
    return "".join(out)


def channels_xml(channels: Sequence[Channel]) -> str:
    return "".join(channel_xml(i, ch) for i, ch in enumerate(channels))


# ---------------------------------------------------------------------------
# План дерева устройств
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Binding:
    """Строка таблицы привязок: сигнал перечня -> ресурс ПЛК210 -> переменная."""

    tag: str
    description: str
    io_ref: str
    resource: str
    variable: str


@dataclass
class Plan:
    job: dict[str, Any]
    bindings: list[Binding]


def _app(path: str) -> str:
    return f"{APP}.{path}"


def _io_signals(signals: Iterable[Signal], module: str) -> list[Signal]:
    return sorted((s for s in signals if s.io_module == module), key=lambda s: s.io_channel or 0)


def _builtin(
    hw: Mapping[str, Any], signals: Sequence[Signal], plan_job: dict[str, Any], bindings: list[Binding]
) -> None:
    builtin = hw["builtin"]
    di, do, ai = builtin["di"], builtin["do"], builtin["ai"]
    for sig in _io_signals(signals, di["io_module"]):
        n = sig.io_channel or 0
        if not 1 <= n <= di["count"]:
            raise PlanError(f"{sig.tag}: канал {sig.io_ref} — у встроенных DI каналов {di['count']}")
        var = _app("GVL_IO." + var_name(sig))
        element = di["element"].format(n=n)
        plan_job["mappings"].append({"device": di["device"], "param": di["param"], "element": element, "variable": var})
        resource = "встроенный " + di["terminal"].format(n=n)
        bindings.append(Binding(sig.tag, sig.description, sig.io_ref, resource, var.removeprefix(APP + ".")))
    for sig in _io_signals(signals, do["io_module"]):
        n = sig.io_channel or 0
        if not 1 <= n <= do["count"]:
            raise PlanError(f"{sig.tag}: канал {sig.io_ref} — у встроенных релейных DO каналов {do['count']}")
        var = _app("GVL_IO." + var_name(sig))
        element = do["element"].format(n=n)
        terminal = do["terminal"].format(t=n + do["terminal_offset"])
        plan_job["mappings"].append({"device": do["device"], "param": do["param"], "element": element, "variable": var})
        resource = "встроенный " + terminal + " (реле)"
        bindings.append(Binding(sig.tag, sig.description, sig.io_ref, resource, var.removeprefix(APP + ".")))
    for sig in _io_signals(signals, ai["io_module"]):
        n = sig.io_channel or 0
        if not 1 <= n <= ai["count"]:
            continue  # каналы сверх встроенных — модули Mx210 (ethernet.modules)
        value_var = _app(f"{PRG_IN}.arAiValue_pct[{n}]")
        status_var = _app(f"{PRG_IN}.ausiAiStatus[{n}]")
        plan_job["mappings"].append(
            {"device": ai["device"], "param": ai["value_param"] + n, "element": None, "variable": value_var}
        )
        plan_job["mappings"].append(
            {"device": ai["device"], "param": ai["status_param"] + n, "element": None, "variable": status_var}
        )
        plan_job["parameters"].append(
            {"device": ai["device"], "param": ai["type_param"] + n, "value": str(ai["sensor_type"])}
        )
        resource = "встроенный " + ai["terminal"].format(n=n) + " (4–20 мА, «Значение» и «Статус»)"
        bindings.append(
            Binding(sig.tag, sig.description, sig.io_ref, resource, "GVL_IO." + var_name(sig) + " ← F_OwenAiToMa")
        )


def _mx210(hw: Mapping[str, Any], signals: Sequence[Signal], plan_job: dict[str, Any], bindings: list[Binding]) -> None:
    eth = hw["ethernet"]
    slaves: list[dict[str, Any]] = []
    for mod in eth["modules"]:
        sigs = [s for s in _io_signals(signals, mod["io_module"]) if (s.io_channel or 0) >= mod["first_channel"]]
        if not sigs:
            continue
        ip = ".".join(str(x) for x in mod["ip"])
        if mod["kind"] == "ai_float":
            if len(sigs) != 1 or sigs[0].io_channel != mod["first_channel"]:
                raise PlanError(f"{mod['name']}: поддержан один вход (вход 1), в перечне {[s.io_ref for s in sigs]}")
            sig = sigs[0]
            var = f"{PRG_IN}.awMx101Ai1"
            ch = Channel(
                3, mod["register"], 2, mod["cycle_ms"], f"{mod['model']}: вход 1, FLOAT32 (младшее слово первым)"
            )
            ch.words = {0: _app(var + "[0]"), 1: _app(var + "[1]")}
            resource = f"{mod['model']} {ip}, вход 1 (регистры {mod['register']}…{mod['register'] + 1})"
            bindings.append(
                Binding(sig.tag, sig.description, sig.io_ref, resource, "GVL_IO." + var_name(sig) + " ← F_Mx210AiToMa")
            )
        elif mod["kind"] == "di_mask":
            ch = Channel(
                3, mod["register"], mod["length"], mod["cycle_ms"], f"{mod['model']}: маска входов DI1…DI20 (UINT32)"
            )
            for sig in sigs:
                k = (sig.io_channel or 0) - mod["first_channel"]  # DI1 -> бит 0
                word, bit = divmod(k, WORD_BITS)
                if word >= mod["length"]:
                    raise PlanError(f"{sig.tag}: вход DI{k + 1} вне маски {mod['model']}")
                var = _app("GVL_IO." + var_name(sig))
                ch.bits[(word, bit)] = var
                resource = f"{mod['model']} {ip}, DI{k + 1} (регистр {mod['register'] + word}, бит {bit})"
                bindings.append(Binding(sig.tag, sig.description, sig.io_ref, resource, var.removeprefix(APP + ".")))
        else:
            raise PlanError(f"{mod['name']}: вид модуля {mod['kind']!r} не поддерживается")
        slaves.append(
            {
                "name": mod["name"],
                "model": mod["model"],
                "ip": "[" + ",".join(str(x) for x in mod["ip"]) + "]",
                "port": mod["port"],
                "unit_id": mod["unit_id"],
                "channels": [_channel_summary(ch)],
                "channels_xml": channels_xml([ch]),
            }
        )
    plan_job["ethernet"] = {"name": eth["name"], "master": eth["master"], "slaves": slaves}


def _channel_summary(ch: Channel) -> dict[str, Any]:
    return {
        "function": ch.function,
        "offset": ch.offset,
        "length": ch.length,
        "cycle_ms": ch.cycle_ms,
        "mapped": len(ch.words) + len(ch.bits),
    }


def _array_name(slave: str, read: bool) -> str:
    return f"aw{slave}{'Rd' if read else 'Wr'}"


def _serial(
    hw: Mapping[str, Any], signals: Sequence[Signal], plan_job: dict[str, Any], bindings: list[Binding]
) -> None:
    mb = [s for s in signals if s.signal_type == "MB"]
    lines: list[dict[str, Any]] = []
    for line in hw["serial"]:
        names = hw["serial_slaves"].get(line["link"], {})
        line_sigs = [s for s in mb if s.mb_link == line["link"]]
        slaves: list[dict[str, Any]] = []
        for address in sorted({s.mb_slave for s in line_sigs if s.mb_slave is not None}):
            name = names.get(str(address))
            if not name:
                raise PlanError(f"{line['link']}: у слейва {address} нет имени в hardware.json (serial_slaves)")
            channels: list[Channel] = []
            for func in (16, 3, 4):
                regs = sorted(
                    (s for s in line_sigs if s.mb_slave == address and s.mb_func == func), key=lambda s: s.mb_reg or 0
                )
                if not regs:
                    continue
                first = regs[0].mb_reg or 0
                words: list[tuple[int, Signal]] = []
                for sig in regs:
                    size = 2 if sig.mb_type in ("REAL", "DWORD") else 1
                    words.extend(((sig.mb_reg or 0) + i, sig) for i in range(size))
                addresses = [a for a, _ in words]
                if addresses != list(range(first, first + len(words))):
                    raise PlanError(
                        f"{line['link']} слейв {address} {FUNCTION_SHORT[func]}: регистры {addresses} не подряд"
                    )
                read = func in READ_FUNCTIONS
                cycle = 1000 if func == 4 else 100
                ch = Channel(
                    func, first, len(words), cycle, f"{name}: {FUNCTION_SHORT[func]} {first}…{first + len(words) - 1}"
                )
                array = (PRG_IN if read else PRG_OUT) + "." + _array_name(name, read)
                ch.words = {k: _app(f"{array}[{k}]") for k in range(len(words))}
                channels.append(ch)
                for sig in regs:
                    res = (
                        f"{line['link']} (COM{line['com_port']}), слейв {address}, {FUNCTION_SHORT[func]} {sig.mb_reg}"
                    )
                    via = PRG_IN if read else PRG_OUT
                    bindings.append(Binding(sig.tag, sig.description, "", res, "GVL_IO." + var_name(sig) + f" ↔ {via}"))
            slaves.append(
                {
                    "name": name,
                    "address": address,
                    "timeout_ms": line["response_timeout_ms"],
                    "channels": [_channel_summary(c) for c in channels],
                    "channels_xml": channels_xml(channels),
                }
            )
        lines.append(
            {
                "name": line["name"],
                "link": line["link"],
                "com_port": line["com_port"],
                "baudrate": line["baudrate"],
                "parity": line["parity"],
                "data_bits": line["data_bits"],
                "stop_bits": line["stop_bits"],
                "master": line["master"],
                "response_timeout_ms": line["response_timeout_ms"],
                "auto_restart": bool(line["auto_restart"]),
                "slaves": slaves,
            }
        )
    plan_job["serial"] = lines


def build_plan(hw: Mapping[str, Any], signals: Sequence[Signal], gvl_io: set[str] | None = None) -> Plan:
    """План дерева устройств: задание скрипту CODESYS и строки таблицы привязок."""
    job: dict[str, Any] = {
        "device": dict(hw["device"]),
        "slot": dict(hw["slot"]),
        "mappings": [],
        "parameters": [],
    }
    bindings: list[Binding] = []
    _builtin(hw, signals, job, bindings)
    _mx210(hw, signals, job, bindings)
    _serial(hw, signals, job, bindings)
    if gvl_io is not None:
        missing = sorted({var_name(s) for s in signals if s.io_module or s.signal_type == "MB"} - gvl_io)
        if missing:
            raise PlanError(f"в GVL_IO нет переменных перечня: {', '.join(missing)}")
    mapped = {b.tag for b in bindings}
    unmapped = [s.tag for s in signals if (s.io_module or s.signal_type == "MB") and s.tag not in mapped]
    if unmapped:
        raise PlanError(f"сигналы без ресурса ПЛК210: {', '.join(unmapped)}")
    return Plan(job, bindings)


def load_plan() -> Plan:
    hw = json.loads(HARDWARE_FILE.read_text(encoding="utf-8"))
    signals = parse_io_list(IO_LIST_FILE.read_text(encoding="utf-8"))
    return build_plan(hw, signals, gvl_names(GVL_IO_FILE.read_text(encoding="utf-8")))


# ---------------------------------------------------------------------------
# Таблица привязок в README
# ---------------------------------------------------------------------------


def table_markdown(bindings: Sequence[Binding]) -> str:
    lines = [
        "| Сигнал | Назначение | Канал перечня | Ресурс ПЛК210 | Переменная |",
        "|---|---|---|---|---|",
    ]
    for b in bindings:
        desc = b.description.replace("|", "/")
        lines.append(f"| {b.tag} | {desc} | {b.io_ref or 'Modbus'} | {b.resource} | `{b.variable}` |")
    return "\n".join(lines) + "\n"


def replace_section(text: str, body: str) -> str:
    if text.count(TABLE_BEGIN) != 1 or text.count(TABLE_END) != 1:
        raise PlanError(f"{README_FILE.name}: нет маркеров таблицы привязок")
    head, rest = text.split(TABLE_BEGIN)
    _, tail = rest.split(TABLE_END)
    return f"{head}{TABLE_BEGIN}\n{body}{TABLE_END}{tail}"


# ---------------------------------------------------------------------------
# Командная строка
# ---------------------------------------------------------------------------


def cmd_table(args: argparse.Namespace) -> int:
    plan = load_plan()
    body = table_markdown(plan.bindings)
    if not args.write and not args.check:
        print(body, end="")
        return 0
    text = README_FILE.read_text(encoding="utf-8")
    new = replace_section(text, body)
    if args.check:
        if new != text:
            print(f"plc210_io: таблица привязок в {README_FILE.relative_to(ROOT)} устарела: table --write")
            return 1
        print(f"plc210_io: таблица привязок актуальна ({len(plan.bindings)} сигналов)")
        return 0
    if new != text:
        README_FILE.write_bytes(new.encode("utf-8"))
    print(f"plc210_io: таблица привязок записана ({len(plan.bindings)} сигналов)")
    return 0


def summarize_result(result: Mapping[str, Any]) -> list[str]:
    """Строки итога для консоли из результата скрипта CODESYS."""
    lines = []
    for key, label in (("tree", "дерево"), ("build", "сборка"), ("generate", "генерация кода")):
        part = result.get(key)
        if isinstance(part, Mapping):
            lines.append(f"{label}: ошибок {part.get('errors', '?')}, предупреждений {part.get('warnings', '?')}")
    return lines


def cmd_apply(args: argparse.Namespace, settings: cli.Settings | None = None) -> int:
    plan = load_plan()
    settings = settings or cli.make_settings()
    project = Path(args.project).resolve()
    if not project.exists():
        print(f"plc210_io: нет проекта {project}: сначала tools_project/targets.py build plc210 (cds.py import)")
        return EXIT_USAGE
    job = dict(plan.job)
    job.update({"tools_codesys": str(TOOLS_CODESYS), "project": str(project), "generate_code": not args.no_generate})
    try:
        with cli.repo_lock(settings, "plc210-io"):
            cli.check_project_state(settings, project, force=False)
            result = cli.run_codesys(settings, str(SCRIPT), job, "plc210-io")
            # дерево устройств живёт только в .project (в src/ его нет): следующий cds.py import не считает
            # проект изменённым в IDE
            cli.record_project_state(settings, project, cli.layout_subdirs(False))
    except cli.CdsError as exc:
        print(f"plc210_io: {exc}")
        return exc.code
    out = Path(args.result) if args.result else None
    if out is not None:
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    for line in result.get("log", []):
        print(f"plc210_io:   {line}")
    for line in summarize_result(result):
        print(f"plc210_io: {line}")
    if not result.get("ok"):
        print(f"plc210_io: ОШИБКА: {result.get('error', 'сборка с ошибками')}")
        return 1
    return 0


def main(argv: Sequence[str] | None = None) -> int:
    for stream in (sys.stdout, sys.stderr):
        reconfigure = getattr(stream, "reconfigure", None)
        if reconfigure is not None:
            reconfigure(encoding="utf-8", errors="replace")
    parser = argparse.ArgumentParser(prog="plc210_io.py", description="Дерево устройств сборки ОВЕН ПЛК210")
    sub = parser.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("table", help="таблица привязок сигналов (targets/plc210/README.md)")
    g = p.add_mutually_exclusive_group()
    g.add_argument("--write", action="store_true", help="записать в README")
    g.add_argument("--check", action="store_true", help="проверить, что README актуален (код 1 — устарел)")
    p = sub.add_parser("apply", help="построить дерево устройств в проекте, собрать, сгенерировать код")
    p.add_argument("--project", required=True, help="проект CODESYS сборки ПЛК210")
    p.add_argument("--result", help="итог в JSON")
    p.add_argument("--no-generate", action="store_true", help="без «Генерировать код»")
    args = parser.parse_args(argv)
    try:
        if args.cmd == "table":
            return cmd_table(args)
        return cmd_apply(args)
    except (PlanError, OSError, ValueError, KeyError) as exc:
        print(f"plc210_io: {exc}")
        return EXIT_USAGE


if __name__ == "__main__":
    sys.exit(main())
