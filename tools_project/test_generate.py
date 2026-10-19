"""Слой устройств: сгенерированные файлы совпадают с генерацией по перечню (DESIGN, разделы 4.5, 4.6).

Перегенерация (iolistgen по docs/03_io_list.csv с iolistgen.toml и список устройств generate.py) во
временный каталог должна побайтно повторить файлы репозитория. Нужен iolistgen (IOLISTGEN_REPO, соседний
каталог или установленный пакет); без него сверка с генератором пропускается, проверки формата — нет.
"""

from __future__ import annotations

import importlib.util
from pathlib import Path

import pytest

import generate as G

ROOT = Path(__file__).resolve().parent.parent


def iolistgen_available() -> bool:
    try:
        G.find_iolistgen(ROOT)
    except G.GenerateError:
        return False
    return True


needs_iolistgen = pytest.mark.skipif(not iolistgen_available(), reason="нет iolistgen (IOLISTGEN_REPO)")


@needs_iolistgen
def test_regeneration_reproduces_repository_files_byte_for_byte() -> None:
    assert G.drift(ROOT) == [], "дрейф генерации: python tools_project/generate.py"


def test_all_generated_files_are_committed() -> None:
    missing = [rel.as_posix() for rel in G.GENERATED_FILES if not (ROOT / rel).is_file()]
    assert not missing


def test_device_list_matches_devidx() -> None:
    devices = G.read_devices((ROOT / G.DEVIDX_FILE).read_text(encoding="utf-8"))
    assert [d.dev_no for d in devices] == sorted(d.dev_no for d in devices)
    assert (ROOT / G.DEVICE_LIST_GVL).read_text(encoding="utf-8") == G.device_list_gvl(devices)
    decl, impl = G.device_list_prg(devices)
    assert (ROOT / G.DEVICE_LIST_PRG / "PRG_DeviceList.decl.st").read_text(encoding="utf-8") == decl
    assert (ROOT / G.DEVICE_LIST_PRG / "PRG_DeviceList.impl.st").read_text(encoding="utf-8") == impl


def test_device_list_shape() -> None:
    devices = G.read_devices((ROOT / G.DEVIDX_FILE).read_text(encoding="utf-8"))
    text = G.device_list_gvl(devices)
    assert f"DEVICE_COUNT : UINT := {len(devices)};" in text
    assert all(len(line) <= G.MAX_LINE for line in text.splitlines())
    _decl, impl = G.device_list_prg(devices)
    assert impl.count("GVL_DeviceList.aitfDevice[") == len(devices)
    # первое устройство — насос Н1 (dev_no 11), последнее — кнопка HS502 (dev_no 502)
    assert (devices[0].tag, devices[0].dev_type) == ("P101", "MotorVfd")
    assert devices[-1].tag == "HS502"


def test_read_devices_rejects_unknown_format() -> None:
    with pytest.raises(G.GenerateError):
        G.read_devices("VAR_GLOBAL CONSTANT\nEND_VAR\n")


def test_command_passes_templates_none_via_set() -> None:
    cmd = G.iolistgen_command(Path("out"), ROOT, strict=True)
    assert cmd[cmd.index("--config") + 1] == "iolistgen.toml"
    sets = [cmd[i + 1] for i, a in enumerate(cmd) if a == "--set"]
    assert sets == list(G.IOLISTGEN_SETS)
    assert cmd[-1] == "--strict"


PRG_DEVICES_IMPL = ROOT / G.GEN_POU_DIR / "PRG_Devices" / "PRG_Devices.impl.st"
TEMPLATE_OVERRIDE = ROOT / "tools_project" / "iolistgen_templates" / "st" / "PRG_Devices.impl.st.j2"
GUARD_FIRST_LINE = "// КНС-1 (перекрытие шаблона iolistgen"
GUARD_LAST_LINE = "END_IF"


def guard_block(text: str) -> tuple[int, int]:
    """Строки (с, по) перекрытия шаблона: проверка GVL_Sim.xIoReady в начале PRG_Devices."""
    lines = text.splitlines()
    first = next(i for i, line in enumerate(lines) if line.startswith(GUARD_FIRST_LINE))
    last = next(i for i in range(first, len(lines)) if lines[i] == GUARD_LAST_LINE)
    return first, last


def test_devices_wait_for_valid_inputs_and_power_device_comes_first() -> None:
    """Подхват насоса при старте ПЛК (ASSUMPTIONS, И3): ES301 (link_power) вызывается раньше насосов и В1,
    а до действительных входов имитации (GVL_Sim.xIoReady, И2) устройства не вызываются вовсе."""
    text = PRG_DEVICES_IMPL.read_text(encoding="utf-8")
    first, last = guard_block(text)
    guard = "\n".join(text.splitlines()[first : last + 1])
    assert "IF NOT GVL_Sim.xIoReady THEN" in guard and "RETURN;" in guard
    calls = [line.split("(")[0] for line in text.splitlines() if line.startswith("GVL_Devices.fb") and "(" in line]
    assert calls[0] == "GVL_Devices.fbES301"
    dependents = ("P101", "P102", "P103", "V1")
    assert text.index("GVL_Devices.fbES301(") < min(text.index(f"GVL_Devices.fb{tag}(") for tag in dependents)
    assert text.index("RETURN;") < text.index("GVL_Devices.fbES301(")


@needs_iolistgen
def test_template_override_differs_from_package_only_by_guard() -> None:
    """Перекрытие шаблона iolistgen (риск R-10 архитектуры): кроме проверки xIoReady — текст шаблона пакета."""
    repo = G.find_iolistgen(ROOT)
    if repo is None:  # пакет установлен в окружение
        spec = importlib.util.find_spec("iolistgen")
        assert spec is not None and spec.origin is not None
        package = Path(spec.origin).resolve().parent
    else:
        package = repo / "iolistgen"
    original = (package / "templates" / "st" / "PRG_Devices.impl.st.j2").read_text(encoding="utf-8")
    override = TEMPLATE_OVERRIDE.read_text(encoding="utf-8")
    lines = override.splitlines(keepends=True)
    first, last = guard_block(override)
    assert lines[first - 1] == "\n", "перед проверкой — пустая строка"
    assert "".join(lines[: first - 1] + lines[last + 1 :]) == original, (
        "шаблон PRG_Devices пакета iolistgen изменился: перенесите правку в tools_project/iolistgen_templates"
    )
