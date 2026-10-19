// 04 §10.1, §11, PMI-19: без уровнемера сухой ход снимается, когда LS103 снят дольше tDryRelease = 60 с (не
// раньше)
METHOD PRIVATE DryRunReleaseWithoutLtAfterTDryRelease
VAR
    fbDut  : FB_Protections;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (tLdev 30 с, tLtRecover 30 с, tDryRelease 60 с)
    fbSink : FB_FakeEventSink;          // подменный журнал
END_VAR
