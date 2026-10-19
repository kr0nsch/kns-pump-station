// 25 записей (три порции FILE.Write по 10 строк): выгрузка завершается Done, строк 25, ошибки нет
METHOD PRIVATE WritesHeaderAndAllLines
VAR_INST
    fbLog    : FB_EventLog;         // журнал со снимком
    fbCsv    : FB_EventLogCsv;      // проверяемая выгрузка
    uiPolls : UINT;                // вызовов теста с начала
    xStarted : BOOL;                // записи и снимок готовы
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    uiI    : UINT;                  // номер события
END_VAR
