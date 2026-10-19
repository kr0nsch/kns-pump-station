// Возврат отложенной тревоги по номеру: TRUE и снова ActiveUnack; повторно — FALSE (не отложена)
METHOD PRIVATE UnshelveById
VAR_INST
    fbDut  : FB_AlarmSummary;       // проверяемая сводка
    stView : ST_AlarmView;          // список тревог
    fbSrc  : FB_TestAlarmSource;    // одна тревога
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    itfAlm : PL.I_Alarm;            // проверяемая тревога источника
END_VAR
