// 04 §10.5: при уровнемере в норме (Good) виноват поплавок — исключается поплавок, уровнемер остаётся в логике
METHOD PRIVATE GoodLtContradictingFloatMasksFloat
VAR
    fbDut  : FB_Protections;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (tLdev 30 с, tLtRecover 30 с, tDryRelease 60 с)
    fbSink : FB_FakeEventSink;          // подменный журнал
END_VAR
