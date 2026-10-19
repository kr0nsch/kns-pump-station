"""Протокол клиента ПЛК — один для обоих исполнителей сценариев (DESIGN, раздел 14.3).

Пути — от имени GVL (``GVL_Station.stStationSts.uiLeadPump``, элемент массива ``axVfdFault[2]``),
значения — ``bool``, ``int``, ``float``. ``read`` и ``write`` — пакетом, одним запросом.
"""

from __future__ import annotations

import re
from collections.abc import Mapping, Sequence
from typing import Literal, Protocol

from kns_scenarios.values import PlcValue

ResetKind = Literal["warm", "cold"]
_PLACEHOLDER_RE = re.compile(r"\{(\w+)\}")


class NotSupportedError(Exception):
    """Операция недоступна этому исполнителю (сброс ПЛК в исполнителе OPC UA)."""


class PlcClient(Protocol):
    """Клиент ПЛК: исполнитель OPC UA (asyncua) или онлайн-мост CODESYS."""

    def read(self, paths: Sequence[str]) -> list[PlcValue]:
        """Значения путей пакетом, в том же порядке."""
        ...

    def write(self, values: Mapping[str, PlcValue]) -> None:
        """Запись пакетом, одним запросом."""
        ...

    def reset(self, kind: ResetKind) -> None:
        """Тёплый или холодный сброс приложения; OPC UA — ``NotSupportedError``."""
        ...

    def close(self) -> None:
        """Закрыть соединение."""
        ...


def substitute(template: str, captures: Mapping[str, PlcValue]) -> str:
    """Подстановка ``{имя}`` значениями ``capture`` сценария: ``fbP10{lead}`` → ``fbP102``."""

    def repl(m: re.Match[str]) -> str:
        name = m.group(1)
        if name not in captures:
            raise KeyError(f"значение {{{name}}} не захвачено (capture) до использования в «{template}»")
        value = captures[name]
        if isinstance(value, bool):
            return "TRUE" if value else "FALSE"
        if isinstance(value, float) and value.is_integer():
            return str(int(value))
        return str(value)

    return _PLACEHOLDER_RE.sub(repl, template)
