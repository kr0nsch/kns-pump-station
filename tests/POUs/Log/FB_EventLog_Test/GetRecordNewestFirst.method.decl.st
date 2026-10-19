// Возраст 0 — самая новая запись; возраст за последней записью — FALSE
METHOD PRIVATE GetRecordNewestFirst
VAR_INST
    fbLog  : FB_EventLog;           // проверяемый журнал
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    stRec  : ST_EventRecord;        // запись
END_VAR
