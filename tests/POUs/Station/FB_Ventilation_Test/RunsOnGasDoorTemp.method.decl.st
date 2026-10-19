// 04 §17, PMI-38: В1 работает при газе выше H, открытой двери, температуре выше H
METHOD PRIVATE RunsOnGasDoorTemp
VAR
    fbDut  : FB_Ventilation;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию: выбег 10 мин
    fbDut2 : FB_Ventilation;           // дверь
    fbDut3 : FB_Ventilation;           // температура
END_VAR
