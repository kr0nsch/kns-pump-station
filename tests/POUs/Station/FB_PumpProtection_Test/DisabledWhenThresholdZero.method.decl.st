// 04 §18.2 № 28: rUnderload_A = 0 — контроль выключен
METHOD PRIVATE DisabledWhenThresholdZero
VAR
    fbDut  : FB_PumpProtection;         // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию: 12 А, 80 %, 15 с
END_VAR
