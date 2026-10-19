#!/usr/bin/env python3
"""Символьная конфигурация OPC UA КНС-1 в проекте ``cds.py`` (docs/DESIGN.md, раздел 13).

Правила — ``tools_project/codesys/symbol_rules.json`` (в ``tools/codesys/config.json`` их нет: набор ключей
файла проверяет тест шаблона), сборка ``sim`` (CODESYS Control Win с имитацией) или ``site`` (ПЛК210).
Скрипт CODESYS ``symbol_config_cds.py`` (IronPython, без окна) создаёт объект Symbol Configuration с
«Support OPC UA features», если его нет, выставляет ``configured_access`` каждой переменной по правилам
(идемпотентно), собирает приложение и генерирует код. Затем этот скрипт читает файл символов
``<проект>.Device.Application.xml``, который пишет генерация кода, и сверяет доступ каждой выгруженной
переменной с правилами: расхождение — код выхода 1.

Порядок: ``cds.py import`` → ``tools_project/codesys/codesys_pvl.py`` (один раз на проект) → этот скрипт.
Объект символьной конфигурации живёт в ``.project`` (в ``src/`` его нет): после нового проекта или
``import --clean`` скрипт запускается снова. Блокировка рабочей копии и запуск CODESYS — как у ``cds.py``.

Коды выхода: 0 — конфигурация совпадает с правилами, 1 — CODESYS не настроил объект или файл символов
расходится с правилами, 2 — нет проекта или неверные правила, 3 и выше — как у ``cds.py``.
"""

from __future__ import annotations

import argparse
import fnmatch
import json
import sys
from collections.abc import Mapping, Sequence
from dataclasses import dataclass
from pathlib import Path
from typing import Any
from xml.etree import ElementTree

ROOT = Path(__file__).resolve().parents[2]
TOOLS_CODESYS = ROOT / "tools" / "codesys"
sys.path[:0] = [str(TOOLS_CODESYS)]

from cdshost import cli  # noqa: E402

HERE = Path(__file__).resolve().parent
RULES_FILE = HERE / "symbol_rules.json"
SCRIPT = HERE / "symbol_config_cds.py"
ACCESS_VALUES = ("Read", "ReadWrite")
EXIT_USAGE = 2
APPLICATION = "Application"


class RulesError(Exception):
    """Неверный файл правил."""


@dataclass(frozen=True)
class Rule:
    """Правило одной сборки: список, шаблоны имён переменных, доступ (None — не выгружать)."""

    gvl: str
    patterns: tuple[str, ...]
    access: str | None

    def to_job(self) -> dict[str, Any]:
        return {"gvl": self.gvl, "vars": list(self.patterns), "access": self.access}


def load_rules(data: Mapping[str, Any], build: str) -> list[Rule]:
    """Правила сборки ``build`` из содержимого ``symbol_rules.json``."""
    builds = data.get("builds", [])
    if build not in builds:
        raise RulesError(f"сборка {build!r} не описана (есть: {', '.join(builds)})")
    rules: list[Rule] = []
    for index, raw in enumerate(data.get("rules", []), 1):
        gvl, patterns, access = raw.get("gvl"), raw.get("vars"), raw.get("access")
        if not isinstance(gvl, str) or not gvl or not isinstance(patterns, list) or not patterns:
            raise RulesError(f"правило {index}: нужны gvl и непустой список vars")
        if isinstance(access, dict):
            unknown = sorted(set(access) - set(builds))
            if unknown:
                raise RulesError(f"правило {index}: неизвестные сборки {unknown}")
            access = access.get(build)
        if access is not None and access not in ACCESS_VALUES:
            raise RulesError(f"правило {index}: доступ {access!r} — допустимо {ACCESS_VALUES} или по сборке")
        rules.append(Rule(gvl, tuple(str(p) for p in patterns), access))
    return rules


def access_for(rules: Sequence[Rule], gvl: str, var: str) -> str | None:
    """Доступ переменной по правилам: первое подходящее правило; без правила — None (как в CODESYS-скрипте)."""
    for rule in rules:
        if rule.gvl.lower() != gvl.lower():
            continue
        if any(fnmatch.fnmatchcase(var.lower(), p.lower()) for p in rule.patterns):
            return rule.access
    return None


def symbol_file(project: Path, device: str) -> Path:
    """Файл символов, который пишет генерация кода: ``<проект>.<устройство>.Application.xml`` рядом с проектом."""
    return project.with_name(f"{project.stem}.{device}.{APPLICATION}.xml")


def _local(tag: str) -> str:
    return tag.rsplit("}", 1)[-1]


def parse_symbols(text: str) -> dict[str, dict[str, str]]:
    """Выгруженные переменные файла символов: список → {переменная: доступ}.

    Узлы ``<Node name=...>``: под узлом приложения — списки и программы, под ними — переменные с
    атрибутом ``access``. Вложенные элементы структур (свои ``Node`` в типах) не считаются.
    """
    root = ElementTree.fromstring(text)
    result: dict[str, dict[str, str]] = {}
    for app in root.iter():
        if _local(app.tag) != "Node" or app.get("name") != APPLICATION:
            continue
        for gvl in app:
            if _local(gvl.tag) != "Node":
                continue
            variables = {
                var.get("name", ""): var.get("access", "")
                for var in gvl
                if _local(var.tag) == "Node" and var.get("access") is not None
            }
            if variables:
                result.setdefault(gvl.get("name", ""), {}).update(variables)
    return result


def verify(symbols: Mapping[str, Mapping[str, str]], rules: Sequence[Rule]) -> list[str]:
    """Расхождения файла символов с правилами: доступ не тот или переменная выгружена без правила."""
    problems = []
    for gvl, variables in sorted(symbols.items()):
        for var, access in sorted(variables.items()):
            expected = access_for(rules, gvl, var)
            if expected != access:
                problems.append(f"{gvl}.{var}: в файле символов {access or 'нет'}, по правилам {expected or 'нет'}")
    return problems


def counts(symbols: Mapping[str, Mapping[str, str]]) -> dict[str, dict[str, int]]:
    """Число выгруженных переменных по спискам и доступу."""
    out: dict[str, dict[str, int]] = {}
    for gvl, variables in symbols.items():
        for access in variables.values():
            out.setdefault(gvl, {}).setdefault(access, 0)
            out[gvl][access] += 1
    return out


def main(argv: Sequence[str] | None = None) -> int:
    for stream in (sys.stdout, sys.stderr):  # Windows по умолчанию пишет в консоль cp1251
        reconfigure = getattr(stream, "reconfigure", None)
        if reconfigure is not None:
            reconfigure(encoding="utf-8", errors="replace")
    parser = argparse.ArgumentParser(prog="symbol_config.py", description="Символьная конфигурация OPC UA КНС-1")
    parser.add_argument("--build", choices=("sim", "site"), default="sim", help="сборка правил (по умолчанию sim)")
    parser.add_argument("--rules", type=Path, default=RULES_FILE, help="файл правил")
    parser.add_argument("--verify-only", action="store_true", help="только сверить файл символов с правилами")
    args = parser.parse_args(argv)
    try:
        rules = load_rules(json.loads(args.rules.read_text(encoding="utf-8")), args.build)
    except (OSError, ValueError, RulesError) as exc:
        print(f"symbol_config: правила {args.rules}: {exc}")
        return EXIT_USAGE
    settings = cli.make_settings(ROOT)
    project = settings.project_path(False)
    if not project.exists():
        print(f"symbol_config: нет проекта {project}: сначала python tools/codesys/cds.py import")
        return EXIT_USAGE
    if not args.verify_only:
        job = {"tools_codesys": str(TOOLS_CODESYS), "project": str(project), "rules": [r.to_job() for r in rules]}
        try:
            with cli.repo_lock(settings, "symbol-config"):
                cli.check_project_state(settings, project, force=False)
                result = cli.run_codesys(settings, str(SCRIPT), job, "symbols")
                cli.record_project_state(settings, project, cli.layout_subdirs(False))
        except cli.CdsError as exc:
            print(f"symbol_config: {exc}")
            return exc.code
        if not result.get("ok"):
            print(f"symbol_config: ОШИБКА: {result.get('error', 'CODESYS не настроил символьную конфигурацию')}")
            return 1
        state = "создан" if result.get("created") else "уже был"
        print(f"symbol_config: объект Symbol Configuration {state}; изменено переменных: {result.get('changed', 0)}")
    path = symbol_file(project, str(settings.value("device.name")))
    if not path.exists():
        print(f"symbol_config: нет файла символов {path} (генерация кода не записала его)")
        return 1
    symbols = parse_symbols(path.read_text(encoding="utf-8-sig"))
    for gvl, by_access in sorted(counts(symbols).items()):
        shown = ", ".join(f"{access} — {n}" for access, n in sorted(by_access.items()))
        print(f"symbol_config:   {gvl}: {shown}")
    problems = verify(symbols, rules)
    for line in problems:
        print(f"symbol_config: расхождение: {line}")
    if problems:
        return 1
    print(f"symbol_config: файл символов {path.name} совпадает с правилами сборки {args.build}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
