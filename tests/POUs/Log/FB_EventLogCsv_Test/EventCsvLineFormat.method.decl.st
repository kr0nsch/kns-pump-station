// Строка CSV: тревога (UTC, код P101.FTS, числа перечислений) и событие станции без часов (пустое время);
// значение — REAL_TO_STRING (3.0 → «3.0», проверено прогоном)
METHOD PRIVATE EventCsvLineFormat
VAR
    stRec : ST_EventRecord;         // запись журнала
END_VAR
