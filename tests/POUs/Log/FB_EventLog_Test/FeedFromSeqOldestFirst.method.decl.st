// Курсор: с № 5 — 32 строки № 5…36 от старой к новой; с № 37 — 4 строки и пустые; с № 41 — строк нет
METHOD PRIVATE FeedFromSeqOldestFirst
VAR_INST
    fbLog  : FB_EventLog;           // проверяемый журнал
    stFeed : ST_EventFeed;          // курсор клиента
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    uiI    : UINT;                  // номер события
END_VAR
