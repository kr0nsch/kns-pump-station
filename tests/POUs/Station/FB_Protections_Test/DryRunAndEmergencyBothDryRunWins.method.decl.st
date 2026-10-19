// 04 §10.2: сухой ход и аварийный уровень одновременно — оба признака (старшинство сухого хода —
// FB_ControlSelector), по поплавкам LS103 останавливает откачку
METHOD PRIVATE DryRunAndEmergencyBothDryRunWins
VAR
    fbDut  : FB_Protections;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (tLdev 30 с, tLtRecover 30 с, tDryRelease 60 с)
    fbSink : FB_FakeEventSink;          // подменный журнал
END_VAR
