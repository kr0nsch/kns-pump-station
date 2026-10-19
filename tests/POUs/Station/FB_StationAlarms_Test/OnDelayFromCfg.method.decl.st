// 05_alarm_list.csv: задержка появления KNS1.LACK 10 с — из Cfg тревоги (не раньше)
METHOD PRIVATE OnDelayFromCfg
VAR
    fbDut  : FB_StationAlarms;          // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // тревоги по умолчанию (05_alarm_list.csv)
    uiStep : UINT;                    // шаг 100 мс
END_VAR
