// 04 §8.2: передача роли не выполняется в аварийном режиме, по поплавкам и при последовательном пуске
// (xHandoverAllowed = FALSE); tMaxContRun = 0 — выключено
METHOD PRIVATE HandoverDisabledInEmergency
VAR
    fbDut    : FB_PumpRotation;                    // ФБ под тестом
    fbTime   : PL.FB_FakeTime;                     // подменное время, старт 1 ч
    stCfg    : ST_StationCfg;                      // уставки по умолчанию (RunHours, tStagger 5 с)
    stRetain : ST_StationRetain;                   // следующий ведущий (Cyclic)
    afbPump  : ARRAY[1..3] OF FB_FakeMotorVfd;     // подменные насосы: доступны, Auto, готовы, стоят
    fbSink   : FB_FakeEventSink;                   // подменный журнал
    fbDut2   : FB_PumpRotation;                    // второй экземпляр: tMaxContRun = 0
    stCfg0   : ST_StationCfg;                      // уставки с tMaxContRun = 0
END_VAR
