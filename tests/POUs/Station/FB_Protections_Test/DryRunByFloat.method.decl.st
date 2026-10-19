// 04 §10.1, PMI-19: поплавок LS103 сработал — сухой ход сразу (защита срабатывает до проверки согласования)
METHOD PRIVATE DryRunByFloat
VAR
    fbDut  : FB_Protections;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (tLdev 30 с, tLtRecover 30 с, tDryRelease 60 с)
    fbSink : FB_FakeEventSink;          // подменный журнал
END_VAR
