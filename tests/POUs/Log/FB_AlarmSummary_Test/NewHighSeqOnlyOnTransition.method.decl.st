// Счётчик новых High/Critical растёт только на переходе в ActiveUnack: держится, не растёт от Medium, снова
// растёт после возврата и повторного появления
METHOD PRIVATE NewHighSeqOnlyOnTransition
VAR_INST
    fbDut  : FB_AlarmSummary;       // проверяемая сводка
    stView : ST_AlarmView;          // список тревог
    fbSrc  : FB_TestAlarmSource;    // источник: High, Medium
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
END_VAR
