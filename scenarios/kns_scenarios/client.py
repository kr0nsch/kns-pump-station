"""Протокол клиента ПЛК — один для обоих исполнителей сценариев (DESIGN, раздел 14.3).

Пути — от имени GVL (``GVL_Station.stStationSts.uiLeadPump``, элемент массива ``axVfdFault[2]``),
значения — ``bool``, ``int``, ``float``. ``read`` и ``write`` — пакетом, одним запросом.

Подстановка ``{…}`` в путях и литералах сценария: имя значения ``capture`` или метки ``mark`` (``fbP10{lead}``)
или арифметика над ними — числа, ``+ - * /``, скобки, сравнения и ``and``/``or``/``not`` (``{s1+1}``,
``{t_off-t_low}``, ``{0.2*(e1-h1+e2-h2+e3-h3)}``). Сравнение даёт ``TRUE``/``FALSE``, в арифметике — 1/0.
Вызовы функций, атрибуты и индексы не допускаются: это не ``eval``.
"""

from __future__ import annotations

import ast
import operator
import re
from collections.abc import Callable, Mapping, Sequence
from typing import Any, Literal, Protocol

from kns_scenarios.values import PlcValue

ResetKind = Literal["warm", "cold"]
PLACEHOLDER_RE = re.compile(r"\{([^{}]+)\}")


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


_BIN_OPS: dict[type[ast.operator], Callable[[Any, Any], Any]] = {
    ast.Add: operator.add,
    ast.Sub: operator.sub,
    ast.Mult: operator.mul,
    ast.Div: operator.truediv,
}
_CMP_OPS: dict[type[ast.cmpop], Callable[[Any, Any], Any]] = {
    ast.Eq: operator.eq,
    ast.NotEq: operator.ne,
    ast.Lt: operator.lt,
    ast.LtE: operator.le,
    ast.Gt: operator.gt,
    ast.GtE: operator.ge,
}


def placeholder_names(expr: str) -> set[str]:
    """Имена значений сценария в выражении подстановки (для офлайн-проверки: определены ли они раньше)."""
    return {node.id for node in ast.walk(ast.parse(expr.strip(), mode="eval")) if isinstance(node, ast.Name)}


def evaluate(expr: str, captures: Mapping[str, PlcValue]) -> PlcValue:
    """Значение подстановки ``{expr}``; неизвестное имя — ``KeyError``, недопустимая форма — ``ValueError``."""
    try:
        tree = ast.parse(expr.strip(), mode="eval")
    except SyntaxError as exc:
        raise ValueError(f"подстановка {{{expr}}}: не разобрана ({exc.msg})") from None
    return _eval(tree.body, captures, expr)


def _number(value: PlcValue, expr: str) -> int | float:
    if isinstance(value, str):
        raise ValueError(f"подстановка {{{expr}}}: строка в арифметике")
    return value


def _eval(node: ast.AST, captures: Mapping[str, PlcValue], expr: str) -> PlcValue:
    if isinstance(node, ast.Constant) and isinstance(node.value, bool | int | float):
        return node.value
    if isinstance(node, ast.Name):
        if node.id not in captures:
            raise KeyError(f"значение {{{node.id}}} не захвачено (capture, mark) до использования в «{{{expr}}}»")
        return captures[node.id]
    if isinstance(node, ast.UnaryOp):
        operand = _eval(node.operand, captures, expr)
        if isinstance(node.op, ast.Not):
            return not operand
        if isinstance(node.op, ast.USub):
            return -_number(operand, expr)
        if isinstance(node.op, ast.UAdd):
            return +_number(operand, expr)
    if isinstance(node, ast.BinOp) and type(node.op) in _BIN_OPS:
        left = _number(_eval(node.left, captures, expr), expr)
        right = _number(_eval(node.right, captures, expr), expr)
        result: PlcValue = _BIN_OPS[type(node.op)](left, right)
        return result
    if isinstance(node, ast.Compare):
        left_value = _eval(node.left, captures, expr)
        for op, comparator in zip(node.ops, node.comparators, strict=True):
            right_value = _eval(comparator, captures, expr)
            if type(op) not in _CMP_OPS or not _CMP_OPS[type(op)](left_value, right_value):
                return False
            left_value = right_value
        return True
    if isinstance(node, ast.BoolOp):
        values = [bool(_eval(v, captures, expr)) for v in node.values]
        return all(values) if isinstance(node.op, ast.And) else any(values)
    raise ValueError(f"подстановка {{{expr}}}: допустимы имена, числа, + - * /, сравнения, and/or/not")


def format_value(value: PlcValue) -> str:
    """Значение подстановки → текст литерала: ``TRUE``/``FALSE``, целое без «.0», иначе число."""
    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"
    if isinstance(value, float) and value.is_integer():
        return str(int(value))
    return str(value)


def substitute(template: str, captures: Mapping[str, PlcValue]) -> str:
    """Подстановка ``{…}`` значениями ``capture``/``mark`` сценария: ``fbP10{lead}`` → ``fbP102``, ``{s+1}`` → ``6``."""
    return PLACEHOLDER_RE.sub(lambda m: format_value(evaluate(m.group(1), captures)), template)
