// 56 активных тревог (7 источников по 8): в списке ALM_VIEW_ROWS строк, uiActiveTotal — настоящее число
METHOD PRIVATE ViewLimitedToRows
VAR_INST
    fbDut  : FB_AlarmSummary;       // проверяемая сводка
    stView : ST_AlarmView;          // список тревог
    afbSrc : ARRAY[1..7] OF FB_TestAlarmSource;   // источники по 8 тревог
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    uiS    : UINT;                  // источник
    uiK    : UINT;                  // слот
END_VAR
