"""Отчёт прогона сценариев ПМИ: ``build/pmi-results.json`` и ``.md`` — заготовка протокола 07 (DESIGN 14.3).

По каждому пункту — номер, итог («соответствует» / «не соответствует» / «не проверялось» с причиной),
вид исполнения (``mode``: авто, авто + ручн.), измеренные задержки, размахи и скорости, исполнитель, ускорение,
метки времени процесса и поле ``manual`` (что отмечает инженер). Протокол ``docs/07_test_protocol.md`` заполняет
инженер.
"""

from __future__ import annotations

import json
from collections.abc import Sequence
from dataclasses import asdict
from pathlib import Path

from kns_scenarios.scenario import ScenarioResult

MODE_TEXT = {"auto": "авто", "auto+manual": "авто + ручн.", "manual": "ручн."}  # 06, приложение А, «Вид»


def to_json(results: Sequence[ScenarioResult]) -> str:
    items = []
    for r in results:
        item = asdict(r)
        item["verdict"] = r.verdict
        items.append(item)
    return json.dumps({"results": items}, ensure_ascii=False, indent=1, default=str) + "\n"


def to_markdown(results: Sequence[ScenarioResult]) -> str:
    lines = [
        "# Прогон сценариев ПМИ на имитаторе",
        "",
        "Заготовка для `docs/07_test_protocol.md`: итог и измеренные значения по пунктам; вид экранов, права",
        "ролей и файл журнала отмечает инженер (колонка «Вручную»).",
        "",
        "| № | Проверка | Итог | Вид | Исполнитель | k | Измерено | Вручную | Замечания |",
        "|---|---|---|---|---|---:|---|---|---|",
    ]
    for r in results:
        measured = (
            "; ".join(
                f"{k}: {v:.3f}" + ("" if "размах" in k or "скорость" in k else " с") for k, v in r.measured.items()
            )
            or "—"
        )
        notes = [f"{c.step}: {c.text} — {c.actual!r}" for c in r.checks if c.ok is False]
        notes += [f"{c.step}: {c.note}" for c in r.checks if c.ok is None and c.note]
        if r.error:
            notes.insert(0, r.error)
        manual = ", ".join(r.manual) or "—"
        remark = "<br>".join(n.replace("|", "\\|") for n in notes) or "—"
        lines.append(
            f"| {r.id} | {r.title} | {r.verdict} | {MODE_TEXT.get(r.mode, r.mode)} | {r.backend} | {r.time_scale:g} | "
            f"{measured} | {manual} | {remark} |"
        )
    return "\n".join(lines) + "\n"


def write_reports(results: Sequence[ScenarioResult], out_dir: Path) -> tuple[Path, Path]:
    out_dir.mkdir(parents=True, exist_ok=True)
    js, md = out_dir / "pmi-results.json", out_dir / "pmi-results.md"
    js.write_text(to_json(results), encoding="utf-8")
    md.write_text(to_markdown(results), encoding="utf-8")
    return js, md
