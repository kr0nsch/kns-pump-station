// 04 §6: два насоса, уровень сразу ниже останова — оба останавливаются одним переходом через 5 с
METHOD PRIVATE TwoToZeroAtStopLevel
VAR
    fbDut  : FB_LevelControlStepped;    // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (04 §18.2)
END_VAR
