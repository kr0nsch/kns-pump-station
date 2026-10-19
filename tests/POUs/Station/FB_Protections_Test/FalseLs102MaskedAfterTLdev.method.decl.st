// 04 §10.5, PMI-23: LS102 сработал при уровне ниже 3,50 м — через tLdev поплавок исключён (101011, 102), аварийный
// режим снят
METHOD PRIVATE FalseLs102MaskedAfterTLdev
VAR
    fbDut  : FB_Protections;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (tLdev 30 с, tLtRecover 30 с, tDryRelease 60 с)
    fbSink : FB_FakeEventSink;          // подменный журнал
END_VAR
