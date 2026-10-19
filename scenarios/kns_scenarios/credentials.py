"""Учётные данные рантайма для сценариев: тот же файл, что у ``tools/codesys`` (DESIGN, раздел 14.3).

Путь — ``CODESYS_RUNTIME_CREDENTIALS`` или ``~/.local/plc-tools/cds-runtime/credentials.json`` (вне
репозитория). Пароль не выводится ни в лог, ни в отчёт: у ``Credentials`` он скрыт из ``repr``.
"""

from __future__ import annotations

import json
import os
from dataclasses import dataclass, field
from pathlib import Path

ENV_VAR = "CODESYS_RUNTIME_CREDENTIALS"
DEFAULT_PATH = Path("~/.local/plc-tools/cds-runtime/credentials.json")


class CredentialsError(Exception):
    """Нет файла учётных данных или в нём нет user и password."""


@dataclass(frozen=True)
class Credentials:
    """Имя и пароль пользователя рантайма."""

    user: str
    password: str = field(repr=False)


def credentials_path(path: Path | None = None) -> Path:
    """Явный путь, переменная окружения или путь по умолчанию."""
    if path is not None:
        return path
    raw = os.environ.get(ENV_VAR)
    return Path(raw) if raw else DEFAULT_PATH.expanduser()


def load_credentials(path: Path | None = None) -> Credentials:
    """Прочитать ``{"user": ..., "password": ...}``; ``CredentialsError`` — без значения пароля в тексте."""
    target = credentials_path(path)
    try:
        data = json.loads(target.read_text(encoding="utf-8"))
    except OSError as exc:
        raise CredentialsError(f"нет файла учётных данных {target} ({exc.strerror})") from None
    except ValueError:
        raise CredentialsError(f"{target}: не JSON") from None
    user, password = data.get("user"), data.get("password")
    if not isinstance(user, str) or not user or not isinstance(password, str):
        raise CredentialsError(f"{target}: нужны поля user и password")
    return Credentials(user, password)
