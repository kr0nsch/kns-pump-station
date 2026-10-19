// 04 §6, PMI-02: один насос, уровень 1,00 м (граница останова) — останов ровно через 5 с
METHOD PRIVATE StopsAllAtStopLevel
VAR
    fbDut  : FB_LevelControlStepped;    // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (04 §18.2)
END_VAR
