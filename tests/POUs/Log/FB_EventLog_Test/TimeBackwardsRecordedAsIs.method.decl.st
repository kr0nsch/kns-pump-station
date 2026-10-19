// «Время назад» (подменные часы с 1 ч на 59 мин 50 с): запись не теряется, номер растёт, метка — как дали часы
METHOD PRIVATE TimeBackwardsRecordedAsIs
VAR_INST
    fbLog  : FB_EventLog;           // проверяемый журнал
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    stRec  : ST_EventRecord;        // запись
END_VAR
