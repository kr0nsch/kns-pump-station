// 04 §11, PMI-21, PMI-25: по поплавкам — ожидание LS102, затем откачка всеми насосами до LS103
METHOD PRIVATE FloatModeStartsAllOnLs102StopsOnLs103
VAR
    fbDut  : FB_Protections;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (tLdev 30 с, tLtRecover 30 с, tDryRelease 60 с)
    fbSink : FB_FakeEventSink;          // подменный журнал
END_VAR
