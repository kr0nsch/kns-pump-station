// 04 §10.3, PMI-29: ток недостоверен (нет связи) или не конечен — контроля недогрузки нет
METHOD PRIVATE NoUnderloadWhenCurrentInvalid
VAR
    fbDut  : FB_PumpProtection;         // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию: 12 А, 80 %, 15 с
    uBits  : PL.U_RealBits;            // сборка NaN по битам
END_VAR
