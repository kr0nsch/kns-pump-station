// Высший неквитированный приоритет не зависит от порядка обхода: Critical в слоте 0, Low в слоте 1 (обе
// неквитированы) → Critical, а не приоритет последней найденной
METHOD PRIVATE PrioUnackHighestBeforeLower
VAR_INST
    fbDut  : FB_AlarmSummary;       // проверяемая сводка
    stView : ST_AlarmView;          // список тревог
    fbSrc  : FB_TestAlarmSource;    // источник: Critical, Low
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
END_VAR
