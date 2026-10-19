// 205 событий в кольцо на 200: записей 200, затёрто 5, самая старая — № 6, самая новая — № 205
METHOD PRIVATE RingOverwritesOldestAndCounts
VAR_INST
    fbLog  : FB_EventLog;           // проверяемый журнал
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    stRec  : ST_EventRecord;        // запись
    uiI    : UINT;                  // номер события
END_VAR
