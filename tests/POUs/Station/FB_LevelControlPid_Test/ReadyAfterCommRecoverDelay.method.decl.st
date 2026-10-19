// 04 §12, PMI-28: связь пропала у всех — готовность снимается сразу; вернулась — готовность через STN_PID_RECOVER
// = 30 с, не раньше
METHOD PRIVATE ReadyAfterCommRecoverDelay
VAR
    fbDut   : FB_LevelControlPid;           // ФБ под тестом
    fbTime  : PL.FB_FakeTime;               // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;                // уставки по умолчанию (04 §18.2)
    afbPump : ARRAY[1..3] OF FB_FakeMotorVfd;   // подменные насосы
    uiStep  : UINT;                     // шаг 100 мс
END_VAR
