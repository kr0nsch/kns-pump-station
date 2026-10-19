// 04 §3.2, PMI-07: вход без рывка — число насосов по работающим, при уровне между остановом и пуском насос не
// останавливается
METHOD PRIVATE InitFromRunningPumpsNoStop
VAR
    fbDut  : FB_LevelControlStepped;    // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (04 §18.2)
END_VAR
