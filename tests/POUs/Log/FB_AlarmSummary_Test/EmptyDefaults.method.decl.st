// Без источников: счётчики 0, неквитированных нет, список пуст, первый вызов пересчитывает список
METHOD PRIVATE EmptyDefaults
VAR_INST
    fbDut  : FB_AlarmSummary;       // проверяемая сводка
    stView : ST_AlarmView;          // список тревог
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    uiI    : UINT;                  // приоритет
END_VAR
