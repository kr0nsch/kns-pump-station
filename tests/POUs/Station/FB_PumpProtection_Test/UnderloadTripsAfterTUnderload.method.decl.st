// 04 §10.3, PMI-15: ток ниже 12 А на частоте не ниже 80 % дольше tUnderload = 15 с — фиксация недогрузки и бит
// KNS_ILK_UNDERLOAD, не раньше
METHOD PRIVATE UnderloadTripsAfterTUnderload
VAR
    fbDut  : FB_PumpProtection;         // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию: 12 А, 80 %, 15 с
END_VAR
