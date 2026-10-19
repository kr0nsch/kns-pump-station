// 04 §3.2, PMI-07: вход без рывка — число насосов по работающим, не больше MIN(2, uiDutyMax)
METHOD PRIVATE InitFromRunningPumps
VAR
    fbDut   : FB_LevelControlPid;           // ФБ под тестом
    fbTime  : PL.FB_FakeTime;               // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;                // уставки по умолчанию (04 §18.2)
    afbPump : ARRAY[1..3] OF FB_FakeMotorVfd;   // подменные насосы
    fbDut2  : FB_LevelControlPid;          // второй экземпляр: uiDutyMax = 1
    stCfg1  : ST_StationCfg;               // уставки с uiDutyMax = 1
END_VAR
