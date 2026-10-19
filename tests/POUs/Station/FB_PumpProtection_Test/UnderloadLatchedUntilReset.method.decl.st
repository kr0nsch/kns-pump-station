// 04 §10.3, PMI-15: фиксация держится, когда насос остановлен и ток вернулся, — до сброса насоса
METHOD PRIVATE UnderloadLatchedUntilReset
VAR
    fbDut  : FB_PumpProtection;         // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию: 12 А, 80 %, 15 с
END_VAR
