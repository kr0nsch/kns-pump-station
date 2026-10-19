#!/usr/bin/env python3
"""Сборки КНС-1 для целевых ПЛК: ОВЕН ПЛК210 (CODESYS 3.5.17.30) и REGUL R500 61 (Astra.IDE 1.7.2.2).

Описание сборки — ``targets/<имя>/target.json``: устройство, задачи режима normal, правки исходников
(``patches``: точная замена строки, каждая — ровно одно вхождение), каталог дополнительных объектов
(``overlay``) и шаг после импорта (``post``: ``plc210_io`` — дерево устройств ПЛК210). Исходники репозитория не
меняются: сборка идёт в рабочем каталоге ``build/targets/<имя>/root`` (``src/`` — копия ``src/`` с правками и
объектами ``overlay``, ``config.json`` — копия ``tools/codesys/config.json`` с устройством и задачами сборки), тем же
``tools/codesys/cds.py`` через ``CDS_REPO_ROOT`` и ``CDS_CONFIG``. Библиотека plc-process-lib должна быть
установлена в репозиторий библиотек среды (``cds.py deps`` в CODESYS; в Astra.IDE — docs/USAGE.md), сборка идёт
с ``--no-deps``.

Команды::

    python tools_project/targets.py list
    python tools_project/targets.py build plc210      импорт, дерево устройств, сборка, «Генерировать код»
    python tools_project/targets.py build r500        импорт и сборка в Astra.IDE
    python tools_project/targets.py check plc210      cds.py check --tests: все объекты src/ и tests/ на устройстве

Итог — ``build/targets/<имя>/result.json``. Коды выхода — как у ``cds.py`` (0 — без ошибок, 1 — ошибки сборки).
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from collections.abc import Mapping, Sequence
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
TOOLS_CODESYS = ROOT / "tools" / "codesys"
CDS = TOOLS_CODESYS / "cds.py"
TARGETS_DIR = ROOT / "targets"
WORK_DIR = ROOT / "build" / "targets"
EXIT_USAGE = 2
_VAR_RE = re.compile(r"\$\{([A-Za-z_][A-Za-z0-9_()]*)\}")


class TargetError(Exception):
    """Неверное описание сборки или исходники не совпадают с правками."""


def load_target(name: str, targets_dir: Path = TARGETS_DIR) -> dict[str, Any]:
    path = targets_dir / name / "target.json"
    if not path.is_file():
        known = ", ".join(sorted(p.parent.name for p in targets_dir.glob("*/target.json")))
        raise TargetError(f"нет сборки {name!r} (есть: {known})")
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise TargetError(f"{path}: ожидался объект JSON")
    for key in ("title", "ide", "device", "tasks"):
        if key not in data:
            raise TargetError(f"{path}: нет ключа {key}")
    if data["ide"] not in ("codesys", "astra"):
        raise TargetError(f"{path}: ide = {data['ide']!r}, ожидалось codesys или astra")
    return data


def apply_patches(src_root: Path, patches: Sequence[Mapping[str, str]]) -> list[str]:
    """Правки исходников сборки: каждая строка from встречается в файле ровно один раз."""
    done: list[str] = []
    for patch in patches:
        path = src_root / patch["file"]
        text = path.read_text(encoding="utf-8")
        count = text.count(patch["from"])
        if count != 1:
            raise TargetError(f"{patch['file']}: строка {patch['from'].strip()!r} встречается {count} раз, ожидался 1")
        path.write_bytes(text.replace(patch["from"], patch["to"]).encode("utf-8"))
        done.append(f"{patch['file']}: {patch['to'].strip()}")
    return done


def compose(name: str, target: Mapping[str, Any], repo: Path = ROOT, work: Path = WORK_DIR) -> Path:
    """Рабочий каталог сборки: src/ (копия, правки, overlay) и config.json. Возвращает корень."""
    root = work / name / "root"
    if (root / "src").exists():
        shutil.rmtree(root / "src")
    root.mkdir(parents=True, exist_ok=True)
    shutil.copytree(repo / "src", root / "src")
    overlay = target.get("overlay")
    if overlay:
        src = repo / overlay
        for path in sorted(src.rglob("*.st")):
            dest = root / "src" / path.relative_to(src)
            if dest.exists():
                raise TargetError(
                    f"{overlay}: {path.relative_to(src)} уже есть в src/ — overlay только добавляет объекты"
                )
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(path, dest)
    apply_patches(root, target.get("patches") or [])
    config = json.loads((repo / "tools" / "codesys" / "config.json").read_text(encoding="utf-8"))
    config["project"]["name"] = f"{repo.name}-{name}"
    device = target["device"]
    for key in ("type", "id", "version", "title"):
        config["device"][key] = device[key]
    config["modes"]["normal"]["tasks"] = list(target["tasks"])
    (root / "config.json").write_text(json.dumps(config, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return root


def expand(text: str, environ: Mapping[str, str]) -> str:
    def var(match: re.Match[str]) -> str:
        value = environ.get(match.group(1))
        if value is None:
            raise TargetError(f"переменная окружения {match.group(1)} не задана (нужна для {text})")
        return value

    return _VAR_RE.sub(var, text)


def _setting(node: Any, environ: Mapping[str, str]) -> str:
    if isinstance(node, Mapping):
        value = environ.get(str(node.get("env"))) if node.get("env") else None
        return value if value is not None else expand(str(node["default"]), environ)
    return expand(str(node), environ)


def target_env(target: Mapping[str, Any], root: Path | None, environ: Mapping[str, str]) -> dict[str, str]:
    """Окружение cds.py: рабочий каталог сборки, устройство; для Astra.IDE — среда и свой учёт библиотек."""
    env = dict(environ)
    for key in ("CDS_PROJECT", "CDS_TEST_PROJECT", "CDS_PROJECT_NAME", "CDS_REPO_ROOT", "CDS_CONFIG"):
        env.pop(key, None)
    device = target["device"]
    env.update(
        {
            "CDS_DEVICE_TYPE": str(device["type"]),
            "CDS_DEVICE_ID": str(device["id"]),
            "CDS_DEVICE_VERSION": str(device["version"]),
            "CDS_DEVICE_TITLE": str(device["title"]),
        }
    )
    if root is not None:
        env["CDS_REPO_ROOT"] = str(root)
        env["CDS_CONFIG"] = str(root / "config.json")
    if target["ide"] == "astra":
        astra = target["astra"]
        env["CODESYS_EXE"] = _setting(astra["exe"], environ)
        env["CODESYS_PROFILE"] = _setting(astra["profile"], environ)
        env["CDS_LIBRARY_REGISTRY"] = expand(astra["library_registry"], environ)
        env["CDS_LIBRARY_LOCK"] = expand(astra["library_lock"], environ)
    return env


def run_cds(args: Sequence[str], env: Mapping[str, str]) -> int:
    print(f"[targets] cds.py {' '.join(args)}", flush=True)
    return subprocess.call([sys.executable, str(CDS), *args], env=dict(env), cwd=str(ROOT))


def read_json(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return {}
    return data if isinstance(data, dict) else {}


def cmd_build(name: str, environ: Mapping[str, str]) -> int:
    target = load_target(name)
    root = compose(name, target)
    env = target_env(target, root, environ)
    result: dict[str, Any] = {"target": name, "title": target["title"], "device": target["device"]}
    if target.get("post") == "plc210_io":
        code = run_cds(["import", "--no-deps"], env)
        result["import"] = read_json(root / "build" / "import.json")
        if code != 0:
            return _finish(name, result, code)
        sys.path[:0] = [str(ROOT / "tools_project" / "codesys"), str(TOOLS_CODESYS)]
        import plc210_io
        from cdshost import cli

        settings = cli.make_settings(root, env)
        out = WORK_DIR / name / "plc210_io.json"
        args = argparse.Namespace(project=str(settings.project_path(False)), result=str(out), no_generate=False)
        code = plc210_io.cmd_apply(args, settings)
        result["plc210_io"] = read_json(out)
        return _finish(name, result, code)
    code = run_cds(["build", "--no-deps"], env)
    result["build"] = read_json(root / "build" / "build.json")
    return _finish(name, result, code)


def _finish(name: str, result: dict[str, Any], code: int) -> int:
    result["exit_code"] = code
    path = WORK_DIR / name / "result.json"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"[targets] {name}: {'OK' if code == 0 else 'ОШИБКА'} (итог: {path.relative_to(ROOT)})")
    return code


def cmd_check(name: str, environ: Mapping[str, str]) -> int:
    """cds.py check --tests на устройстве сборки: все объекты src/ и tests/ репозитория (без overlay)."""
    target = load_target(name)
    env = target_env(target, None, environ)
    work = WORK_DIR / name
    env["CDS_PROJECT"] = str(work / "check" / f"{ROOT.name}.project")
    env["CDS_TEST_PROJECT"] = str(work / "check" / f"{ROOT.name}-tests.project")
    tests = [] if target["ide"] == "astra" else ["--tests"]  # coUnit в Astra.IDE не установлена
    return run_cds(["check", *tests, "--no-deps"], env)


def main(argv: Sequence[str] | None = None) -> int:
    for stream in (sys.stdout, sys.stderr):
        reconfigure = getattr(stream, "reconfigure", None)
        if reconfigure is not None:
            reconfigure(encoding="utf-8", errors="replace")
    parser = argparse.ArgumentParser(prog="targets.py", description="Сборки КНС-1 для целевых ПЛК")
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("list", help="сборки из targets/*/target.json")
    for cmd in ("build", "check"):
        p = sub.add_parser(cmd)
        p.add_argument("target", help="имя каталога в targets/")
    args = parser.parse_args(argv)
    try:
        if args.cmd == "list":
            for path in sorted(TARGETS_DIR.glob("*/target.json")):
                t = load_target(path.parent.name)
                dev = t["device"]
                print(f"{path.parent.name}: {t['title']} ({dev['type']} / {dev['id']} / {dev['version']})")
            return 0
        if args.cmd == "build":
            return cmd_build(args.target, os.environ)
        return cmd_check(args.target, os.environ)
    except (TargetError, OSError, ValueError, KeyError) as exc:
        print(f"targets: {exc}")
        return EXIT_USAGE


if __name__ == "__main__":
    sys.exit(main())
