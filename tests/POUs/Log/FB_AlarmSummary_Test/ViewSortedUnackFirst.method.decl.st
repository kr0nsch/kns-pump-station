// Порядок списка: неквитированные (Medium выше Low), затем активные квитированные (High), затем отложенные
METHOD PRIVATE ViewSortedUnackFirst
VAR_INST
    fbDut  : FB_AlarmSummary;       // проверяемая сводка
    stView : ST_AlarmView;          // список тревог
    fbSrc  : FB_TestAlarmSource;    // слоты: 0 Low, 1 High (квитирована), 2 Medium, 3 Medium (отложена)
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
END_VAR
