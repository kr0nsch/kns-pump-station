// 04 §10.5, PMI-22: LS103 сработал при уровне выше 0,80 м и уровнемере в норме — через tLdev поплавок исключён
// (101011, 103), KNS1.LDEV, сухой ход снят
METHOD PRIVATE FalseLs103MaskedAfterTLdev
VAR
    fbDut  : FB_Protections;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (tLdev 30 с, tLtRecover 30 с, tDryRelease 60 с)
    fbSink : FB_FakeEventSink;          // подменный журнал
END_VAR
