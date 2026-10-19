// 04 §10.5: LS103 не сработал при уровне ниже 0,20 м и уровнемере в норме — через tLdev KNS1.LDEV, защиту держит
// LL уровнемера
METHOD PRIVATE Ls103NotTrippedBelowOffMark
VAR
    fbDut  : FB_Protections;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (tLdev 30 с, tLtRecover 30 с, tDryRelease 60 с)
    fbSink : FB_FakeEventSink;          // подменный журнал
END_VAR
