// Событие тревоги: запись вида Alarm со всеми полями события, номер 1, время процесса — по itfTime (1 ч)
METHOD PRIVATE AlarmEventStored
VAR_INST
    fbLog  : FB_EventLog;           // проверяемый журнал
END_VAR
VAR
    fbTime  : PL.FB_FakeTime;       // подменное время, старт 1 ч
    stEvent : PL.ST_AlarmEvent;     // событие тревоги
    stRec   : ST_EventRecord;       // записанная запись
END_VAR
