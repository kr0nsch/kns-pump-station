"""Курсор журнала событий ``GVL_Log.stEventFeed`` для сценариев (DESIGN, разделы 3.2, 14.3).

Клиент пишет ``udiFromSeq`` — первый нужный номер, ПЛК (``FB_EventLog.FillFeed`` в каждом цикле MainTask)
отдаёт до LOG_FEED_ROWS записей от старой к новой. Интервалы между событиями ПЛК сценарии берут из
меток ``lrMono_s`` (время процесса): погрешность — цикл задачи при любом ускорении. Пропуск номеров
(записи затёрты между опросами) — ошибка сценария (``JournalGap``). Журнал в ОЗУ: после сброса или
перезапуска ПЛК номера снова начинаются с 1 — курсор замечает, что последний номер ПЛК меньше уже
прочитанного, и переходит на первую запись нового журнала (``restarts``), а не ждёт прежних номеров.
"""

from __future__ import annotations

from collections.abc import Iterable
from dataclasses import dataclass

from kns_scenarios.client import PlcClient

FEED = "GVL_Log.stEventFeed"
FEED_ROWS = 32  # GVL_Const.LOG_FEED_ROWS
STATION_EVENT_BASE = 101000  # GVL_Const.STN_EVENT_ID_BASE
RECORD_FIELDS = (
    "udiSeq",
    "eKind",
    "ePriority",
    "udiId",
    "eOldState",
    "eNewState",
    "eReason",
    "rValue",
    "uliUtc_ms",
    "lrMono_s",
)
HEADER_FIELDS = ("udiFromSeq", "udiSeqFirst", "udiSeqLast", "uiCount")


class JournalGap(Exception):
    """Записи журнала затёрты между опросами: курсор отстал от кольца."""


@dataclass(frozen=True)
class EventRecord:
    """Запись журнала (ST_EventRecord)."""

    seq: int
    kind: int
    priority: int
    id: int
    old_state: int
    new_state: int
    reason: int
    value: float
    utc_ms: int
    mono_s: float

    @property
    def is_station_event(self) -> bool:
        return self.id >= STATION_EVENT_BASE


def event_id(code: str) -> int:
    """Код события станции ``KNS1.E6`` → номер 101006."""
    prefix = "KNS1.E"
    if not code.startswith(prefix) or not code[len(prefix) :].isdigit():
        raise ValueError(f"код события {code!r}: ожидается KNS1.E<код>")
    return STATION_EVENT_BASE + int(code[len(prefix) :])


class EventFeed:
    """Чтение журнала курсором: каждый ``poll`` возвращает новые записи по порядку номеров."""

    def __init__(self, client: PlcClient, rows: int = FEED_ROWS) -> None:
        self.client = client
        self.rows = rows
        self.next_seq = 1
        self.records: list[EventRecord] = []
        self.restarts = 0  # замечено перезапусков журнала (сброс ПЛК)

    def _paths(self, rows: int | None = None) -> list[str]:
        """Пути заголовка и строк 1…``rows`` (без аргумента — все строки курсора)."""
        paths = [f"{FEED}.{name}" for name in HEADER_FIELDS]
        for row in range(1, (self.rows if rows is None else rows) + 1):
            paths += [f"{FEED}.astRow[{row}].{name}" for name in RECORD_FIELDS]
        return paths

    def last_seq(self) -> int:
        """Номер последней записи журнала ПЛК (0 — записей нет)."""
        return int(self.client.read([f"{FEED}.udiSeqLast"])[0])

    def start_at_end(self) -> int:
        """Пропустить уже записанное: следующий номер — после последней записи журнала."""
        self.next_seq = self.last_seq() + 1
        self.client.write({f"{FEED}.udiFromSeq": self.next_seq})
        return self.next_seq

    def start_at_first(self) -> int:
        """Читать с самой старой записи кольца (PMI-01: события старта приложения, записанные до сценария)."""
        self.next_seq = max(int(self.client.read([f"{FEED}.udiSeqFirst"])[0]), 1)
        self.client.write({f"{FEED}.udiFromSeq": self.next_seq})
        return self.next_seq

    def poll(self) -> list[EventRecord]:
        """Новые записи с номера ``next_seq``; курсор сдвигается за последнюю прочитанную."""
        # заголовок, затем только заполненные строки: у OPC UA-сервера CODESYS предел 100 узлов в запросе, все
        # 32 строки — это 320 узлов; номер записи в строке от udiFromSeq не меняется, пока запись не затёрта
        header = self.client.read(self._paths(0))
        _from, first, last, count = (int(v) for v in header)
        filled = min(count, self.rows)
        values = header + (self.client.read(self._paths(filled)[len(HEADER_FIELDS) :]) if filled else [])
        if last + 1 < self.next_seq:
            # номера ПЛК пошли назад: журнал начат заново (сброс, перезапуск) — читать с его первой записи
            self.restarts += 1
            self.next_seq = first
            self.client.write({f"{FEED}.udiFromSeq": self.next_seq})
            return []
        if self.next_seq < first:
            raise JournalGap(f"записи {self.next_seq}…{first - 1} затёрты между опросами журнала")
        width = len(RECORD_FIELDS)
        fresh: list[EventRecord] = []
        for row in range(min(count, self.rows)):
            raw = values[len(HEADER_FIELDS) + row * width : len(HEADER_FIELDS) + (row + 1) * width]
            rec = EventRecord(
                int(raw[0]),
                int(raw[1]),
                int(raw[2]),
                int(raw[3]),
                int(raw[4]),
                int(raw[5]),
                int(raw[6]),
                float(raw[7]),
                int(raw[8]),
                float(raw[9]),
            )
            if rec.seq == self.next_seq:  # строки до записи нового udiFromSeq пропускаются
                fresh.append(rec)
                self.next_seq += 1
        self.client.write({f"{FEED}.udiFromSeq": self.next_seq})
        self.records.extend(fresh)
        return fresh


def find(
    records: Iterable[EventRecord],
    *,
    id: int,
    new_state: int | None = None,
    after_mono_s: float | None = None,
    after_seq: int | None = None,
) -> EventRecord | None:
    """Первая запись с номером ``id`` (и состоянием ``new_state``) не раньше ``after_mono_s`` и с номером
    журнала больше ``after_seq``."""
    for rec in records:
        if rec.id != id or (new_state is not None and rec.new_state != new_state):
            continue
        if after_mono_s is not None and rec.mono_s < after_mono_s:
            continue
        if after_seq is not None and rec.seq <= after_seq:
            continue
        return rec
    return None
