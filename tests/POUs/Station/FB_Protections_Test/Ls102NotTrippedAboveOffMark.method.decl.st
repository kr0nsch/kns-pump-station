// 04 §10.5, PMI-24: LS102 не сработал при уровне выше 4,40 м — через tLdev KNS1.LDEV; аварийный режим держит HH
// уровнемера, маски нет
METHOD PRIVATE Ls102NotTrippedAboveOffMark
VAR
    fbDut  : FB_Protections;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (tLdev 30 с, tLtRecover 30 с, tDryRelease 60 с)
    fbSink : FB_FakeEventSink;          // подменный журнал
END_VAR
