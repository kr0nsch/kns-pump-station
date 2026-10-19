"""targets.py без CODESYS: описания сборок, рабочий каталог (правки, overlay, config.json), окружение cds.py."""

from __future__ import annotations

import json
from pathlib import Path

import pytest

import targets as T


def test_targets_load() -> None:
    plc = T.load_target("plc210")
    assert plc["ide"] == "codesys"
    assert plc["device"] == {"type": 4096, "id": "1628 0083", "version": "3.5.17.35", "title": "ОВЕН ПЛК210"}
    main = plc["tasks"][0]["pous"]
    assert main[0] == "PRG_FieldBusIn_Plc210" and main[-1] == "PRG_FieldBusOut_Plc210"
    assert "PRG_PlantModel" not in json.dumps(plc["tasks"])
    r500 = T.load_target("r500")
    assert r500["ide"] == "astra" and r500["device"]["id"] == "109B 0008"
    assert sorted(t["priority"] for t in r500["tasks"]) == [5, 6, 14]
    with pytest.raises(T.TargetError, match="нет сборки"):
        T.load_target("nope")


def test_patches_apply_once(tmp_path: Path) -> None:
    f = tmp_path / "src" / "a.st"
    f.parent.mkdir()
    f.write_text("X : BOOL := TRUE;\n", encoding="utf-8")
    patch = {"file": "src/a.st", "from": "X : BOOL := TRUE;", "to": "X : BOOL := FALSE;"}
    assert T.apply_patches(tmp_path, [patch]) == ["src/a.st: X : BOOL := FALSE;"]
    assert f.read_text(encoding="utf-8") == "X : BOOL := FALSE;\n"
    with pytest.raises(T.TargetError, match="0 раз"):
        T.apply_patches(tmp_path, [patch])


def test_target_patches_match_sources() -> None:
    """Строки правок сборки ПЛК210 есть в src/ ровно по разу (иначе сборка не запустится)."""
    for patch in T.load_target("plc210")["patches"]:
        text = (T.ROOT / patch["file"]).read_text(encoding="utf-8")
        assert text.count(patch["from"]) == 1, patch["file"]


def test_compose_plc210(tmp_path: Path) -> None:
    target = T.load_target("plc210")
    root = T.compose("plc210", target, work=tmp_path)
    assert (root / "src" / "POUs" / "FieldBus" / "PRG_FieldBusIn_Plc210" / "PRG_FieldBusIn_Plc210.decl.st").is_file()
    assert "SIM_ALLOWED : BOOL := FALSE;" in (root / "src" / "GVLs" / "GVL_Const.gvl.st").read_text(encoding="utf-8")
    config = json.loads((root / "config.json").read_text(encoding="utf-8"))
    assert config["device"]["id"] == "1628 0083" and config["device"]["title"] == "ОВЕН ПЛК210"
    assert config["device"]["keep_tasks"] == ["OwenCloudTask"]
    assert config["project"]["name"] == f"{T.ROOT.name}-plc210"
    assert config["modes"]["normal"]["tasks"] == target["tasks"]
    assert (
        config["modes"]["test"]
        == json.loads((T.ROOT / "tools/codesys/config.json").read_text(encoding="utf-8"))["modes"]["test"]
    )
    # повторный compose пересоздаёт src/
    (root / "src" / "stale.st").write_text("", encoding="utf-8")
    T.compose("plc210", target, work=tmp_path)
    assert not (root / "src" / "stale.st").exists()


def test_overlay_must_not_replace_sources(tmp_path: Path) -> None:
    repo = tmp_path / "repo"
    (repo / "src").mkdir(parents=True)
    (repo / "src" / "a.st").write_text("", encoding="utf-8")
    (repo / "ov").mkdir()
    (repo / "ov" / "a.st").write_text("", encoding="utf-8")
    (repo / "tools" / "codesys").mkdir(parents=True)
    (repo / "tools" / "codesys" / "config.json").write_text("{}", encoding="utf-8")
    target = {"overlay": "ov", "patches": [], "device": {}, "tasks": []}
    with pytest.raises(T.TargetError, match="только добавляет"):
        T.compose("x", target, repo=repo, work=tmp_path / "w")


def test_env_codesys_and_astra(tmp_path: Path) -> None:
    environ = {"ProgramFiles": "C:\\PF", "LOCALAPPDATA": "C:\\L", "CDS_PROJECT": "stale.project"}
    env = T.target_env(T.load_target("plc210"), tmp_path, environ)
    assert env["CDS_DEVICE_ID"] == "1628 0083" and env["CDS_DEVICE_TITLE"] == "ОВЕН ПЛК210"
    assert env["CDS_REPO_ROOT"] == str(tmp_path) and env["CDS_CONFIG"] == str(tmp_path / "config.json")
    assert "CDS_PROJECT" not in env and "CODESYS_EXE" not in env
    env = T.target_env(T.load_target("r500"), None, environ)
    assert env["CODESYS_EXE"] == "C:\\PF/AstraRegul/Astra.IDE_64_1.7.2.2/Astra.IDE/Common/Astra.IDE.exe"
    assert env["CODESYS_PROFILE"] == "Astra.IDE_V1.7.2.2"
    assert env["CDS_LIBRARY_REGISTRY"] == "C:\\L/plc-tools/astra-libraries.json"
    assert "CDS_REPO_ROOT" not in env
    env = T.target_env(T.load_target("r500"), None, {**environ, "ASTRA_IDE_EXE": "D:\\A.exe"})
    assert env["CODESYS_EXE"] == "D:\\A.exe"
    with pytest.raises(T.TargetError, match="LOCALAPPDATA"):
        T.target_env(T.load_target("r500"), None, {"ProgramFiles": "C:\\PF"})
