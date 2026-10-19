// 04 §10.4, PMI-16: перегрев обмотки — бит KNS_ILK_OVERHEAT, пока сигнал активен, без фиксации
METHOD PRIVATE OverheatInterlockWhileActive
VAR
    fbDut  : FB_PumpProtection;         // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию: 12 А, 80 %, 15 с
END_VAR
