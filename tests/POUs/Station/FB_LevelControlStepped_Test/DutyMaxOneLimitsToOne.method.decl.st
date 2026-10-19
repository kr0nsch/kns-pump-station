// 04 §18.2 № 13: uiDutyMax = 1 — не больше одного насоса и при инициализации, и выше уровня пуска подпорного
METHOD PRIVATE DutyMaxOneLimitsToOne
VAR
    fbDut  : FB_LevelControlStepped;    // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (04 §18.2)
END_VAR
