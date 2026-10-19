// 04 §10.1, PMI-18: снятие сухого хода — LS103 не сработал, нет LL и уровень выше L (по флагу L уровнемера)
METHOD PRIVATE DryRunReleaseAboveL
VAR
    fbDut  : FB_Protections;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (tLdev 30 с, tLtRecover 30 с, tDryRelease 60 с)
    fbSink : FB_FakeEventSink;          // подменный журнал
END_VAR
