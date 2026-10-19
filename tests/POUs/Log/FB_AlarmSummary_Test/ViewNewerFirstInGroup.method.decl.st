// Внутри группы и приоритета новые выше: три неквитированные Medium, появившиеся с интервалом 1 с (№ 150, 151,
// 152), — в списке 152, 151, 150
METHOD PRIVATE ViewNewerFirstInGroup
VAR_INST
    fbDut  : FB_AlarmSummary;       // проверяемая сводка
    stView : ST_AlarmView;          // список тревог
    fbSrc  : FB_TestAlarmSource;    // слоты 0…2, Medium
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    uiK    : UINT;                  // слот
END_VAR
