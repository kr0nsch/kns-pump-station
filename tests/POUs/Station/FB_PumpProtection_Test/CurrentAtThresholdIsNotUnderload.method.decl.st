// 04 §10.3: ток ровно 12 А — не недогрузка (строго меньше порога)
METHOD PRIVATE CurrentAtThresholdIsNotUnderload
VAR
    fbDut  : FB_PumpProtection;         // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию: 12 А, 80 %, 15 с
END_VAR
