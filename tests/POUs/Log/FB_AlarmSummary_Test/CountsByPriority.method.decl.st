// Активные Low, Medium, High неквитированные и Critical квитированная: активных по одной на приоритет,
// неквитированных — Low, Medium, High
METHOD PRIVATE CountsByPriority
VAR_INST
    fbDut  : FB_AlarmSummary;       // проверяемая сводка
    stView : ST_AlarmView;          // список тревог
    fbSrc1 : FB_TestAlarmSource;    // источник 1: Low, Medium, High
    fbSrc2 : FB_TestAlarmSource;    // источник 2: Critical
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
END_VAR
