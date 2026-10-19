// «Время назад»: список пересчитывается сразу (разность LTIME без знака не считается)
METHOD PRIVATE TimeBackwardsRebuildsView
VAR_INST
    fbDut  : FB_AlarmSummary;       // проверяемая сводка
    stView : ST_AlarmView;          // список тревог
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
END_VAR
