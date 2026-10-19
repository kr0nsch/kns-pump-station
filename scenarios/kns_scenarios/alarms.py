"""Тревоги в сценариях: коды по ``docs/05_alarm_list.csv``, состояние ISA-18.2 по ``GVL_Log.stAlarmView``.

``stAlarmView`` содержит все тревоги в состоянии, отличном от ``Normal`` (в том числе отложенные, подавленные
и выведенные из работы, DESIGN, раздел 3.2): нет строки с номером тревоги — ``Normal``. Если тревог не в
``Normal`` больше, чем строк списка (``uiActiveTotal > uiCount``), отсутствие строки ничего не говорит: состояние
такой тревоги — ``UNKNOWN``, и ожидание ``Normal`` не завершается ложным успехом.
"""

from __future__ import annotations

import csv
from collections.abc import Mapping
from dataclasses import dataclass
from pathlib import Path

from kns_scenarios.client import PlcClient
from kns_scenarios.values import EnumTable

ALARM_VIEW = "GVL_Log.stAlarmView"
VIEW_ROWS = 50  # GVL_Const.ALM_VIEW_ROWS
ALARM_LIST = Path(__file__).resolve().parents[2] / "docs" / "05_alarm_list.csv"
NORMAL = "Normal"
UNKNOWN = "Unknown"  # тревоги нет в переполненном списке
STATE_ENUM = "E_AlarmState"


@dataclass(frozen=True)
class AlarmDef:
    """Строка перечня тревог 05: номер, код, тег, слот, источник, приоритет."""

    id: int
    code: str
    tag: str
    slot: int
    source: str
    priority: str


def load_alarm_list(path: Path = ALARM_LIST) -> dict[str, AlarmDef]:
    """Перечень тревог: код → описание (строки «#» — комментарии)."""
    lines = [ln for ln in path.read_text(encoding="utf-8").splitlines() if ln.strip() and not ln.startswith("#")]
    out: dict[str, AlarmDef] = {}
    for row in csv.DictReader(lines, delimiter=";"):
        out[row["code"]] = AlarmDef(
            int(row["id"]), row["code"], row["tag"], int(row["slot"]), row["source"], row["priority"]
        )
    return out


class AlarmView:
    """Состояние тревоги по коду: строка ``stAlarmView`` с её номером или ``Normal``."""

    def __init__(self, client: PlcClient, catalog: Mapping[str, AlarmDef], enums: EnumTable) -> None:
        self.client = client
        self.catalog = catalog
        states = enums.get(STATE_ENUM, {})
        self.state_names = {value: name for name, value in states.items()}

    def alarm_id(self, code: str) -> int:
        if code not in self.catalog:
            raise KeyError(f"тревоги {code} нет в 05_alarm_list.csv")
        return self.catalog[code].id

    def code_of(self, alarm_id: int) -> str:
        """Код тревоги по номеру (для отчёта); неизвестный номер — сам номер."""
        for code, item in self.catalog.items():
            if item.id == alarm_id:
                return code
        return str(alarm_id)

    def _read(self) -> tuple[dict[int, str], bool]:
        """Номер тревоги → имя состояния по строкам списка и признак переполнения списка."""
        count_raw, total_raw = self.client.read([f"{ALARM_VIEW}.uiCount", f"{ALARM_VIEW}.uiActiveTotal"])
        count = min(int(count_raw), VIEW_ROWS)
        paths: list[str] = []
        for row in range(1, count + 1):
            paths += [f"{ALARM_VIEW}.astRow[{row}].udiId", f"{ALARM_VIEW}.astRow[{row}].eState"]
        values = self.client.read(paths) if paths else []
        out: dict[int, str] = {}
        for i in range(0, len(values), 2):
            state = int(values[i + 1])
            out[int(values[i])] = self.state_names.get(state, str(state))
        return out, int(total_raw) > count

    def states(self) -> dict[int, str]:
        """Номер тревоги → имя состояния для всех строк списка."""
        return self._read()[0]

    def state(self, code: str) -> str:
        """Состояние тревоги ``code`` (``ActiveUnack``, ``Normal``…; ``UNKNOWN`` — нет в переполненном списке)."""
        rows, overflow = self._read()
        return rows.get(self.alarm_id(code), UNKNOWN if overflow else NORMAL)
