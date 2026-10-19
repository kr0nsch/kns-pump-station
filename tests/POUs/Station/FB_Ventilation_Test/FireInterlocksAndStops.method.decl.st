// 04 §17, PMI-38: пожар — В1 стоп и блокировка V1_ILK_FIRE при любых условиях
METHOD PRIVATE FireInterlocksAndStops
VAR
    fbDut  : FB_Ventilation;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию: выбег 10 мин
END_VAR
