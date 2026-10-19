// Список пересчитывается раз в ALM_VIEW_PERIOD (500 мс): через 100 мс — нет, через 500 мс — да
METHOD PRIVATE ViewPeriodRespected
VAR_INST
    fbDut  : FB_AlarmSummary;       // проверяемая сводка
    stView : ST_AlarmView;          // список тревог
    fbSrc  : FB_TestAlarmSource;    // источник с одной тревогой
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
END_VAR
