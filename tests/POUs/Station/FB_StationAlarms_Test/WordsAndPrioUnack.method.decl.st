// 04 §19.3: слова wAlmActive, wAlmUnack и высший приоритет неквитированных (Critical EHL выше Low SIM)
METHOD PRIVATE WordsAndPrioUnack
VAR
    fbDut  : FB_StationAlarms;          // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // тревоги по умолчанию (05_alarm_list.csv)
END_VAR
