// 04 §3.2, PMI-30: вход в «Автомат» — роли получают работающие насосы (ещё в Manual в этом цикле), работающий не
// останавливается, ведущий — с меньшей наработкой
METHOD PRIVATE AdoptKeepsRunningPumpsOnAutoEntry
VAR
    fbDut    : FB_PumpRotation;                    // ФБ под тестом
    fbTime   : PL.FB_FakeTime;                     // подменное время, старт 1 ч
    stCfg    : ST_StationCfg;                      // уставки по умолчанию (RunHours, tStagger 5 с)
    stRetain : ST_StationRetain;                   // следующий ведущий (Cyclic)
    afbPump  : ARRAY[1..3] OF FB_FakeMotorVfd;     // подменные насосы: доступны, Auto, готовы, стоят
    fbSink   : FB_FakeEventSink;                   // подменный журнал
END_VAR
