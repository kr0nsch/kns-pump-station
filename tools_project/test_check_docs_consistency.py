"""Тесты сверки документов КНС-1 (check_docs_consistency.py).

1. Документы репозитория согласованы: каждая проверка C01…C19 не находит расхождений.
2. Каждая проверка ловит расхождение: копия docs/ с одной внесённой ошибкой даёт находку.
3. Разбор ST и чисел, пути переменных, шаблоны «по каждому насосу».
4. Снимки совпадают с источниками, если они рядом: docs/alarms.csv и 03_io_list.md — с выводом iolistgen,
   имена сгенерированного слоя — с настоящими GVL генератора, снимок plc-process-lib — с исходниками
   библиотеки (иначе тест пропускается с причиной).
"""

from __future__ import annotations

import json
import shutil
from collections.abc import Callable
from pathlib import Path

import pytest

import check_docs_consistency as C

ROOT = C.REPO_ROOT


@pytest.fixture(scope="module")
def sources() -> C.Sources:
    return C.load_sources(ROOT)


@pytest.mark.parametrize("code", list(C.CHECKS))
def test_documents_are_consistent(sources: C.Sources, code: str) -> None:
    title, fn = C.CHECKS[code]
    findings = fn(sources)
    assert not findings, f"{code} ({title}):\n" + "\n".join(str(f) for f in findings)


def test_main_returns_zero_for_repository(capsys: pytest.CaptureFixture[str]) -> None:
    assert C.main(["--root", str(ROOT)]) == 0
    assert "расхождений: 0" in capsys.readouterr().out


def test_list_prints_all_checks(capsys: pytest.CaptureFixture[str]) -> None:
    assert C.main(["--list"]) == 0
    out = capsys.readouterr().out
    assert all(code in out for code in C.CHECKS)


# --------------------------------------------------------------------------------------------------
# Каждая проверка ловит внесённую ошибку
# --------------------------------------------------------------------------------------------------


def _copy_repo(tmp_path: Path) -> Path:
    shutil.copytree(ROOT / "docs", tmp_path / "docs")
    return tmp_path


def _replace(root: Path, rel: str, old: str, new: str) -> None:
    path = root / "docs" / rel
    text = path.read_text(encoding="utf-8")
    assert old in text, f"в {rel} нет фрагмента для мутации: {old!r}"
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


MUTATIONS: list[tuple[str, str, str, str, str]] = [
    # (проверка, файл, было, стало, ожидаемый фрагмент находки)
    (
        "C01",
        "04_algorithms.md",
        "| 4,20 | поплавок «аварийно высокий уровень» LS102 |",
        "| 4,20 | поплавок LS109 |",
        "LS109",
    ),
    ("C02", "06_PMI.md", "`P101.FTS` (110, Medium)", "`P101.FTS` (111, Medium)", "номер 111"),
    ("C02", "06_PMI.md", "`KNS1.SIM` (100013, Low)", "`KNS1.SIMX` (100013, Low)", "KNS1.SIMX"),
    ("C02", "08_hmi_spec.md", "код (`P101.EXT`)", "код (`P101.EXF`)", "P101.EXF"),
    (
        "C03",
        "05_alarm_list.csv",
        "Насос Н1: нет подтверждения пуска;10",
        "Насос Н1: нет подтверждения;10",
        "P101.FTS.text_ru",
    ),
    ("C04", "04_algorithms.md", "| 5 | `KNS1.ATS` | Medium |", "| 5 | `KNS1.ATS` | High |", "KNS1.ATS: приоритет"),
    ("C04", "DESIGN.md", "`NORES := 4`, `ATS := 5`", "`NORES := 5`, `ATS := 4`", "E_StationAlarm"),
    ("C05", "04_algorithms.md", "дольше `tAssistOn` (30 с)", "дольше `tAssistOn` (35 с)", "tAssistOn"),
    ("C05", "06_PMI.md", "(`tMinStop`, `fbP10n.stSts", "(`tMinStop` = 20 с, `fbP10n.stSts", "tMinStop"),
    (
        "C06",
        "04_algorithms.md",
        "| LT101: HH / H / L / LL | 4,0 / 3,5 / 0,8 / 0,5 |",
        "| LT101: HH / H / L / LL | 4,1 / 3,5 / 0,8 / 0,5 |",
        "LT101: HH",
    ),
    (
        "C06",
        "04_algorithms.md",
        "| 19 | шаг последовательного пуска | `tSeqStep` | 15 |",
        "| 19 | шаг последовательного пуска | `tSeqStep` | 20 |",
        "tSeqStep",
    ),
    (
        "C06",
        "DESIGN.md",
        "rLvlStartAssist_m   : REAL := 2.40;",
        "rLvlStartAssist_m   : REAL := 2.50;",
        "rLvlStartAssist_m",
    ),
    ("C07", "05_alarm_list.csv", "LS102 < 3.5 или > 4.4", "LS102 < 3.6 или > 4.4", "KNS1.LDEV"),
    (
        "C07",
        "05_alarm_list.csv",
        "P101;0;device;Medium;Насос Н1: нет подтверждения пуска;10;",
        "P101;0;device;Medium;Насос Н1: нет подтверждения пуска;12;",
        "P101.FTS: уставка",
    ),
    ("C08", "07_test_protocol.md", "| PMI-38 | Коллектор и павильон:", "| PMI-38 | Коллектор, павильон:", "PMI-38"),
    ("C08", "08_hmi_spec.md", "PMI-36 (баннер и квитирование)", "PMI-46 (баннер и квитирование)", "PMI-46"),
    ("C08", "05_alarm_list.csv", "до 5 мин;PMI-20, PMI-21, PMI-23", "до 5 мин;PMI-20, PMI-21, PMI-02", "KNS1.EHL"),
    (
        "C09",
        "08_hmi_spec.md",
        "событие 101017 журнала (номер параметра)",
        "событие 101037 журнала (номер параметра)",
        "101037",
    ),
    ("C10", "06_PMI.md", "`Sts.eControlAct = Float`", "`Sts.eControlActs = Float`", "eControlActs"),
    ("C10", "06_PMI.md", "`Sts.eControlAct = Float`", "`Sts.eControlAct = Floating`", "Floating"),
    ("C10", "08_hmi_spec.md", "`Sim.stSimSts.rLevel_m`", "`Sim.stSimSts.rLevelTrue_m`", "rLevelTrue_m"),
    ("C10", "06_PMI.md", "`Inj.aeAiFault[1] = WireBreak`", "`Inj.aeAiFault[7] = WireBreak`", "индекс 7"),
    ("C11", "DESIGN.md", "`E_ControlAct.Float`", "`E_ControlAct.Floats`", "Floats"),
    ("C12", "04_algorithms.md", "`FB_EventLog IMPLEMENTS", "`FB_EventJournal IMPLEMENTS", "FB_EventJournal"),
    ("C13", "06_PMI.md", "бит `STN_CFG_SETPOINT`", "бит `STN_CFG_SETPOINTS`", "STN_CFG_SETPOINTS"),
    ("C14", "DESIGN.md", "I_StationEventSink` (04 §16)", "I_StationEventSink`", "04 §16"),
    ("C14", "04_algorithms.md", "| 5 | `Emergency` |", "| 5 | `Emergence` |", "E_ControlAct"),
    ("C14", "04_algorithms.md", "| 1 | `KNS_ILK_UNDERLOAD` |", "| 2 | `KNS_ILK_UNDERLOAD` |", "KNS_ILK_UNDERLOAD"),
    ("C15", "06_PMI.md", "`Sts.wState` бит 10 (LS103 исключён)", "`Sts.wState` бит 9 (LS103 исключён)", "бит 9"),
    ("C17", "DESIGN.md", "(04 §3)", "(04 §33)", "04 §33"),
    (
        "C17",
        "06_PMI.md",
        "[DESIGN.md](DESIGN.md), разделы 3.3, 11, 14",
        "[DESIGN.md](DESIGN.md), разделы 3.3, 11, 41",
        "нет раздела 41",
    ),
    ("C18", "08_hmi_spec.md", "| `LT101` уровень | 0…5 м |", "| `LT101` уровень | 0…5 м | лишняя |", "ячеек"),
    ("C19", "01_TZ.md", "58 сигналов, 29 устройств", "57 сигналов, 29 устройств", "57 сигналов"),
    (
        "C16",
        "08_hmi_spec.md",
        "| High (3) | квадрат с цифрой 2 | оранжевый `#E8590C`, белая цифра | до 15 мин |",
        "| High (3) | квадрат с цифрой 2 | оранжевый `#E8590C`, белая цифра | до 30 мин |",
        "время реакции",
    ),
    ("C20", "ARCHITECTURE.md", "200 записей × 40 байт", "200 записей × 44 байт", "ST_EventRecord"),
    (
        "C20",
        "DESIGN.md",
        "    wReserve        : WORD;               // выравнивание: дальше 32-битные поля\n",
        "",
        "ST_StationSts",
    ),
    ("C03", "06_PMI.md", "SHA-256 `06336d13c4b2`", "SHA-256 `06336d13c4b3`", "SHA-256"),
    ("C17", "05_alarm_list.csv", "06_PMI.md, раздел 5.3", "06_PMI.md, раздел 2.3", "нет раздела 2.3"),
]


@pytest.mark.parametrize(
    ("code", "rel", "old", "new", "expected"), MUTATIONS, ids=[f"{m[0]}-{i}" for i, m in enumerate(MUTATIONS)]
)
def test_check_detects_mutation(tmp_path: Path, code: str, rel: str, old: str, new: str, expected: str) -> None:
    root = _copy_repo(tmp_path)
    _replace(root, rel, old, new)
    findings = C.run_checks(C.load_sources(root), [code])
    assert any(expected in str(f) for f in findings), "\n".join(str(f) for f in findings) or "нет находок"


def test_svg_without_mockup_caption_is_reported(tmp_path: Path) -> None:
    root = _copy_repo(tmp_path)
    svg = root / "docs" / "hmi" / "04_trends.svg"
    svg.write_text(svg.read_text(encoding="utf-8").replace("МАКЕТ", "ЭКРАН"), encoding="utf-8")
    findings = C.run_checks(C.load_sources(root), ["C16"])
    assert any("МАКЕТ" in str(f) and "04_trends" in str(f) for f in findings)


def test_svg_alarm_text_must_match_alarm_list(tmp_path: Path) -> None:
    root = _copy_repo(tmp_path)
    svg = root / "docs" / "hmi" / "03_alarms.svg"
    svg.write_text(
        svg.read_text(encoding="utf-8").replace(">Нет резервного насоса<", ">Нет резервного насоса!<"), encoding="utf-8"
    )
    findings = C.run_checks(C.load_sources(root), ["C16"])
    assert any("KNS1.NORES" in str(f) for f in findings)


def test_missing_injection_binding_is_reported(tmp_path: Path) -> None:
    root = _copy_repo(tmp_path)
    _replace(root, "08_hmi_spec.md", "`xFanNoFeedback` (нет ОС В1), ", "")
    findings = C.run_checks(C.load_sources(root), ["C16"])
    assert any("xFanNoFeedback" in str(f) for f in findings)


def test_semicolon_inside_alarm_field_is_reported(tmp_path: Path) -> None:
    root = _copy_repo(tmp_path)
    _replace(
        root,
        "05_alarm_list.csv",
        "Насос остановлен до сброса, в автомате — АВР",
        "Насос остановлен до сброса; в автомате — АВР",
    )
    findings = C.run_checks(C.load_sources(root), ["C04"])
    assert any("полей" in str(f) for f in findings)


# --------------------------------------------------------------------------------------------------
# Разбор
# --------------------------------------------------------------------------------------------------


@pytest.mark.parametrize(
    ("literal", "seconds"),
    [("T#5S", 5.0), ("T#500MS", 0.5), ("T#10M", 600.0), ("T#4H", 14400.0), ("T#1H30M", 5400.0), ("LTIME#200MS", 0.2)],
)
def test_parse_time(literal: str, seconds: float) -> None:
    assert C.parse_time(literal) == pytest.approx(seconds)


def test_parse_time_rejects_non_time() -> None:
    assert C.parse_time("5S") is None
    assert C.parse_time("T#5X") is None


@pytest.mark.parametrize(("text", "value"), [("1,60", 1.6), ("−0,09", -0.09), ("4 000", 4000.0), ("—", None)])
def test_doc_number(text: str, value: float | None) -> None:
    assert C.doc_number(text) == (pytest.approx(value) if value is not None else None)


def test_st_scalar_kinds() -> None:
    assert C.st_scalar("T#30S") == 30.0
    assert C.st_scalar("TRUE") is True
    assert C.st_scalar("6.06E-4") == pytest.approx(6.06e-4)
    assert C.st_scalar("16#0010") == 16.0
    assert C.st_scalar("PL.E_PidAction.Direct") == "Direct"


ST_SAMPLE = """
{attribute 'qualified_only'}
TYPE E_Mode :
(
    Auto := 1,   // комментарий
    Manual := 2
) INT;
END_TYPE
TYPE ST_Cfg :
STRUCT
    rLevel_m : REAL := 1.40;        // уровень
    tDelay   : TIME := T#5S;
    astItem  : ARRAY[1..GVL_Const.N] OF ST_Item := [(a := 1), (a := 2, b := T#1S)];
END_STRUCT
END_TYPE
FUNCTION_BLOCK FB_Child EXTENDS FB_Base
VAR_INPUT
    xEnable : BOOL;
END_VAR
VAR_OUTPUT
    uiCount : UINT;
END_VAR
VAR
    xHidden : BOOL;
END_VAR
"""


def test_parse_st_types_and_members() -> None:
    idx = C.parse_st(ST_SAMPLE)
    assert idx.types["E_Mode"].kind == "enum"
    assert idx.types["E_Mode"].values == {"Auto": 1, "Manual": 2}
    cfg = idx.types["ST_Cfg"]
    assert cfg.members["rLevel_m"].init == "1.40"
    assert cfg.members["astItem"].type == "ARRAY[1..GVL_Const.N] OF ST_Item"
    items = C.parse_initializer(cfg.members["astItem"].init or "")
    assert items == [{"a": "1"}, {"a": "2", "b": "T#1S"}]
    fb = idx.types["FB_Child"]
    assert fb.base == "FB_Base"
    assert set(fb.members) == {"xEnable", "uiCount"}  # VAR без доступа снаружи не входит


def test_parse_st_global_list() -> None:
    idx = C.parse_st("VAR_GLOBAL CONSTANT\n    N : UINT := 3;\nEND_VAR\n", "GVL_Const")
    assert idx.gvls["GVL_Const"]["N"].init == "3"
    assert idx.gvls["GVL_Const"]["N"].kind == "const"


def _index() -> C.StIndex:
    idx = C.parse_st(ST_SAMPLE)
    idx.merge(C.parse_st("TYPE ST_Item :\nSTRUCT\n    a : INT;\n    b : TIME;\nEND_STRUCT\nEND_TYPE\n"))
    idx.merge(C.parse_st("VAR_GLOBAL\n    stCfg : ST_Cfg;\n    eMode : E_Mode;\nEND_VAR\n", "GVL_X"))
    idx.merge(C.parse_st("VAR_GLOBAL CONSTANT\n    N : UINT := 3;\nEND_VAR\n", "GVL_Const"))
    return idx


def test_resolve_path_ok_and_errors() -> None:
    idx = _index()
    consts = idx.gvls["GVL_Const"]
    ok = C.resolve_path("GVL_X.stCfg.astItem[2].b", idx, consts)
    assert ok.ok and ok.verified and ok.type == "TIME"
    assert not C.resolve_path("GVL_X.stCfg.rLevel", idx, consts).ok
    assert "индекс 4" in C.resolve_path("GVL_X.stCfg.astItem[4].a", idx, consts).message
    assert "нужен индекс" in C.resolve_path("GVL_X.stCfg.astItem.a", idx, consts).message
    assert not C.resolve_path("GVL_Y.stCfg", idx, consts).ok
    assert C.resolve_path("GVL_X.eMode", idx, consts).type == "E_Mode"
    assert C.check_enum_literal(idx, "E_Mode", "Manual") == ""
    assert "нет значения" in C.check_enum_literal(idx, "E_Mode", "Local")


def test_expand_pumps_templates() -> None:
    assert C.expand_pumps("fbP10n.stSts") == ["fbP101.stSts", "fbP102.stSts", "fbP103.stSts"]
    assert C.expand_pumps("IT1n1.FAIL") == ["IT111.FAIL", "IT121.FAIL", "IT131.FAIL"]
    assert C.expand_pumps("KNS1.ULn") == ["KNS1.UL1", "KNS1.UL2", "KNS1.UL3"]
    assert C.expand_pumps("GVL_IO.xMbOk_RS485_1_Sn") == [f"GVL_IO.xMbOk_RS485_1_S{n}" for n in (1, 2, 3)]
    assert C.expand_pumps("fbP10{lead}.stSts")[1] == "fbP102.stSts"
    assert C.expand_pumps("LT101.FAIL") == ["LT101.FAIL"]


def test_doc_aliases_follow_definitions() -> None:
    doc = C.Doc("x.md", "Сокращения: `Sts` — `GVL_Station.stStationSts`, `Hmi.stP101Cmd` —\n  `GVL_Hmi.stP101Cmd`.\n")
    assert C.doc_aliases(doc) == {"Sts": "GVL_Station.stStationSts", "Hmi": "GVL_Hmi"}


def test_markdown_table_and_sections() -> None:
    doc = C.Doc("x.md", "# 1. Раздел\n\n| a | b |\n|---|---|\n| `x` \\| y | 2 |\n\n## 1.2 Подраздел\n\nтекст\n")
    tables = doc.tables()
    assert tables[0].rows[0][1] == ["`x` | y", "2"]
    assert tables[0].section == "1"
    assert doc.section_numbers() == {"1", "1.2"}


# --------------------------------------------------------------------------------------------------
# Снимки и источники
# --------------------------------------------------------------------------------------------------


def test_find_repo_sibling_or_worktree_grandparent(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    # рабочая копия git worktree лежит в <портфолио>/_wt/<имя>: соседние репозитории — на уровень выше
    monkeypatch.delenv("PL_REPO", raising=False)
    lib = tmp_path / "plc-process-lib"
    (lib / "src" / "POUs" / "Devices" / "FB_MotorVfd").mkdir(parents=True)
    main = tmp_path / "kns-pump-station"
    worktree = tmp_path / "_wt" / "kns-io"
    main.mkdir()
    worktree.mkdir(parents=True)
    marker = "src/POUs/Devices/FB_MotorVfd"
    assert C.find_repo("PL_REPO", "plc-process-lib", main, marker) == lib
    assert C.find_repo("PL_REPO", "plc-process-lib", worktree, marker) == lib
    monkeypatch.setenv("PL_REPO", str(tmp_path / "nowhere"))
    assert C.find_repo("PL_REPO", "plc-process-lib", worktree, marker) is None  # явный путь — без поиска


@pytest.fixture(scope="module")
def iolistgen_out(tmp_path_factory: pytest.TempPathFactory) -> Path:
    repo = C.find_repo("IOLISTGEN_REPO", "iolistgen", ROOT, "iolistgen/__init__.py")
    if repo is None:
        pytest.skip("нет репозитория iolistgen (IOLISTGEN_REPO или соседний каталог): сверка с генератором пропущена")
    out = tmp_path_factory.mktemp("iolistgen")
    C.run_iolistgen(repo, ROOT / "docs" / "03_io_list.csv", out)
    return out


@pytest.mark.parametrize("rel", ["alarms.csv", "03_io_list.md"])
def test_generator_documents_match_iolistgen(iolistgen_out: Path, rel: str) -> None:
    expected = (iolistgen_out / "docs" / rel).read_text(encoding="utf-8")
    assert (ROOT / "docs" / rel).read_text(encoding="utf-8") == expected, f"docs/{rel} не совпадает с выводом iolistgen"


def test_derived_generator_names_match_iolistgen(iolistgen_out: Path, sources: C.Sources) -> None:
    real = C.generated_gvl_index(iolistgen_out / "src" / "GVLs" / "Generated")
    derived = C.derive_generator_index(sources.io, sources.io_md)
    for gvl in ("GVL_IO", "GVL_Devices", "GVL_Hmi", "GVL_CfgProject", "GVL_DevIdx", "GVL_Persist"):
        assert set(derived.gvls[gvl]) == set(real.gvls[gvl]), gvl
        for name, var in derived.gvls[gvl].items():
            assert var.type == real.gvls[gvl][name].type, f"{gvl}.{name}"


def test_library_snapshot_matches_sources() -> None:
    repo = C.find_repo("PL_REPO", "plc-process-lib", ROOT, "src/POUs/Devices/FB_MotorVfd")
    if repo is None:
        pytest.skip("нет исходников plc-process-lib 1.0 (PL_REPO): сверка снимка пропущена")
    data = json.loads(C.LIB_SNAPSHOT.read_text(encoding="utf-8"))
    current = C.library_index_from_repo(repo).to_json()
    assert data["types"] == current["types"], (
        "снимок устарел: python tools_project/check_docs_consistency.py --dump-library <PL_REPO>"
    )
    assert data["gvls"] == current["gvls"]


def test_library_snapshot_has_contract_essentials() -> None:
    lib = C.StIndex.from_json(json.loads(C.LIB_SNAPSHOT.read_text(encoding="utf-8")))
    members: Callable[[str], dict[str, C.Var]] = lambda t: lib.members_of(t) or {}  # noqa: E731
    assert {"xAutoRun", "wInterlock", "rSpeedSpAuto_pct", "stSts", "Mode", "Available"} <= set(members("FB_MotorVfd"))
    assert {"xTrack", "rTrack_pct", "rOutAct_pct", "rOut_pct"} <= set(members("FB_PID"))
    assert "AlarmPriority" in members("I_Alarm")  # имя закреплено в контракте 1.0.0 (F-17)
    assert lib.types["E_MotorState"].values["Fault"] == 4
    assert "MOT_WRN_COMM_LOSS" in lib.gvls["GVL_Const"]
