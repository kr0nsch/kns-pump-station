// Время назад — задержка появления тревоги из Cfg отсчитывается заново
METHOD PRIVATE TimeBackwardsOnDelayRestarts
VAR
    fbDut  : FB_StationAlarms;          // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // тревоги по умолчанию (05_alarm_list.csv)
    uiStep : UINT;                    // шаг 100 мс
END_VAR
