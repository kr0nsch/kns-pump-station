// 04 §11, PMI-27: уровнемер снова годен — режим по поплавкам ещё tLtRecover = 30 с, затем выход (101014)
METHOD PRIVATE FloatModeExitAfterTLtRecover
VAR
    fbDut  : FB_Protections;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (tLdev 30 с, tLtRecover 30 с, tDryRelease 60 с)
    fbSink : FB_FakeEventSink;          // подменный журнал
END_VAR
