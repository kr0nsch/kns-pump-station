// Высший неквитированный приоритет: Medium неквитирована, High квитирована → Medium; Critical появилась → Critical
METHOD PRIVATE PrioUnackHighest
VAR_INST
    fbDut  : FB_AlarmSummary;       // проверяемая сводка
    stView : ST_AlarmView;          // список тревог
    fbSrc  : FB_TestAlarmSource;    // источник: Medium, High, Critical
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
END_VAR
