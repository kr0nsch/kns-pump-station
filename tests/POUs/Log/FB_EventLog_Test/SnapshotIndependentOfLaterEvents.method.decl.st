// Снимок — от старой записи к новой; события после снимка его не меняют; индекс вне снимка — FALSE
METHOD PRIVATE SnapshotIndependentOfLaterEvents
VAR_INST
    fbLog  : FB_EventLog;           // проверяемый журнал
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    stRec  : ST_EventRecord;        // запись снимка
END_VAR
