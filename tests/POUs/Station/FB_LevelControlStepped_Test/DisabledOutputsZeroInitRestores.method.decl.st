// DESIGN 6.3: xEnable = FALSE — выход 0, автомат продолжает работу; следующий xInit задаёт состояние по работающим
METHOD PRIVATE DisabledOutputsZeroInitRestores
VAR
    fbDut  : FB_LevelControlStepped;    // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (04 §18.2)
END_VAR
