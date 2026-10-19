"""Подменные клиент ПЛК и часы для тестов обвязки сценариев без OPC UA (DESIGN, раздел 14.3).

``FakePlc`` — словарь путей (чтение неизвестного пути — ``KeyError``, как узел без символа), ``FakeJournalPlc`` —
ещё журнал и курсор ``stEventFeed`` как ``FB_EventLog.FillFeed``, ``FakeClock`` — часы исполнителя: ``sleep``
двигает время, ожидания с таймаутом завершаются без реальных пауз.
"""

from __future__ import annotations

from collections.abc import Callable, Mapping, Sequence

from kns_scenarios.client import NotSupportedError, ResetKind
from kns_scenarios.enums import ENUMS
from kns_scenarios.journal import FEED, FEED_ROWS, RECORD_FIELDS, EventRecord
from kns_scenarios.values import PlcValue

ACTIVE_UNACK = ENUMS["E_AlarmState"]["ActiveUnack"]


class FakePlc:
    """Подменный ``PlcClient``: словарь путей; чтение неизвестного пути — KeyError, как узел без символа."""

    def __init__(self, values: Mapping[str, PlcValue] | None = None) -> None:
        self.values: dict[str, PlcValue] = dict(values or {})
        self.writes: list[dict[str, PlcValue]] = []
        self.on_write: Callable[[Mapping[str, PlcValue]], None] | None = None

    def read(self, paths: Sequence[str]) -> list[PlcValue]:
        return [self.values[p] for p in paths]

    def write(self, values: Mapping[str, PlcValue]) -> None:
        self.writes.append(dict(values))
        self.values.update(values)
        if self.on_write is not None:
            self.on_write(values)

    def reset(self, kind: ResetKind) -> None:
        raise NotSupportedError(kind)

    def close(self) -> None:
        pass


class FakeJournalPlc(FakePlc):
    """Журнал и курсор ``stEventFeed`` как ``FB_EventLog.FillFeed``: строки с MAX(udiFromSeq, первая)."""

    def __init__(self, values: Mapping[str, PlcValue] | None = None) -> None:
        super().__init__(values)
        self.journal: list[EventRecord] = []
        self.values.setdefault(f"{FEED}.udiFromSeq", 0)

    def add(
        self,
        alarm_id: int,
        new_state: int = ACTIVE_UNACK,
        mono_s: float = 0.0,
        *,
        kind: int = 1,
        value: float = 0.0,
        utc_ms: int = 0,
    ) -> EventRecord:
        """Запись журнала: тревога (``kind`` 1) или событие станции (``kind`` 2, номер 101000 + код)."""
        seq = self.journal[-1].seq + 1 if self.journal else 1
        rec = EventRecord(seq, kind, 2, alarm_id, 0, new_state, 1, value, utc_ms, mono_s)
        self.journal.append(rec)
        return rec

    def restart(self) -> None:
        """Тёплый сброс ПЛК: журнал в ОЗУ пуст, номера снова с 1."""
        self.journal = []

    def fill_feed(self) -> None:
        last = self.journal[-1].seq if self.journal else 0
        first = self.journal[0].seq if self.journal else last + 1
        start = max(int(self.values[f"{FEED}.udiFromSeq"]), first)
        rows = [r for r in self.journal if r.seq >= start][:FEED_ROWS]
        self.values.update({f"{FEED}.udiSeqFirst": first, f"{FEED}.udiSeqLast": last, f"{FEED}.uiCount": len(rows)})
        for row in range(1, FEED_ROWS + 1):
            rec = rows[row - 1] if row <= len(rows) else EventRecord(0, 0, 0, 0, 0, 0, 0, 0.0, 0, 0.0)
            raw = (rec.seq, rec.kind, rec.priority, rec.id, rec.old_state, rec.new_state, rec.reason, rec.value,
                   rec.utc_ms, rec.mono_s)  # fmt: skip
            for name, value in zip(RECORD_FIELDS, raw, strict=True):
                self.values[f"{FEED}.astRow[{row}].{name}"] = value

    def read(self, paths: Sequence[str]) -> list[PlcValue]:
        if any(p.startswith(FEED + ".") for p in paths):
            self.fill_feed()
        return super().read(paths)


class FakeClock:
    """Часы исполнителя: ``sleep`` двигает время, ожидания с таймаутом завершаются без реальных пауз."""

    def __init__(self) -> None:
        self.now = 0.0

    def clock(self) -> float:
        return self.now

    def sleep(self, seconds: float) -> None:
        self.now += max(seconds, 0.01)
