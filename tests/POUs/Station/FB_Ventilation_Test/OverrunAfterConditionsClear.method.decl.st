// 04 §17, PMI-38: условия сняты — В1 работает ещё tV1Overrun = 10 мин, затем стоп
METHOD PRIVATE OverrunAfterConditionsClear
VAR
    fbDut  : FB_Ventilation;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию: выбег 10 мин
    uiStep : UINT;                      // шаг 1 с
END_VAR
