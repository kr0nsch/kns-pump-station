// Пустой снимок: файл с одним заголовком, Done, строк 0
METHOD PRIVATE EmptySnapshotHeaderOnly
VAR_INST
    fbLog    : FB_EventLog;         // пустой журнал
    fbCsv    : FB_EventLogCsv;      // проверяемая выгрузка
    uiPolls : UINT;                // вызовов теста с начала
END_VAR
