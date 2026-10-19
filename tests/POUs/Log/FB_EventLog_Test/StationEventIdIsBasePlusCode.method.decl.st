// Событие станции: номер 101000 + код (АВР, код 6 → 101006), вид Station, приоритет None, состояния Normal
METHOD PRIVATE StationEventIdIsBasePlusCode
VAR_INST
    fbLog  : FB_EventLog;           // проверяемый журнал
END_VAR
VAR
    fbTime  : PL.FB_FakeTime;       // подменное время
    itfSink : I_StationEventSink;   // журнал как приёмник событий станции
    stRec   : ST_EventRecord;       // записанная запись
END_VAR
