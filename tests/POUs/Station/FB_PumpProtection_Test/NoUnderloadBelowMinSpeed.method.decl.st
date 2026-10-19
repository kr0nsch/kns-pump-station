// 04 §10.3: частота ниже rUnderloadSpeed_pct — контроля нет; ровно 80 % — контроль есть (граница включительно)
METHOD PRIVATE NoUnderloadBelowMinSpeed
VAR
    fbDut  : FB_PumpProtection;         // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию: 12 А, 80 %, 15 с
    fbDut2 : FB_PumpProtection;        // второй экземпляр: ровно 80 %
END_VAR
