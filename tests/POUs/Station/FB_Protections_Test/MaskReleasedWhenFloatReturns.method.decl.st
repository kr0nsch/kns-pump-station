// 04 §10.5, PMI-22 шаг 2: маска снимается сама, когда поплавок вернулся (101012, 103)
METHOD PRIVATE MaskReleasedWhenFloatReturns
VAR
    fbDut  : FB_Protections;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (tLdev 30 с, tLtRecover 30 с, tDryRelease 60 с)
    fbSink : FB_FakeEventSink;          // подменный журнал
END_VAR
