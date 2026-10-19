// 04 §9.1, §16, PMI-15, PMI-16: блокировка станции (недогрузка, перегрев) — в цикле отказа насос ещё доступен и
// запрошен (FB_PumpRotation снимет запрос со следующего цикла). Событие 101006 называет замену, а не сам снятый АВР
// насос
METHOD PRIVATE TripEventNamesReplacementNotTrippedPump
VAR
    fbDut   : FB_Ats;                          // ФБ под тестом
    fbTime  : PL.FB_FakeTime;                  // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;                   // уставки по умолчанию (uiDutyMax = 2)
    afbPump : ARRAY[1..3] OF FB_FakeMotorVfd;  // подменные насосы: доступны, Auto
    fbSink  : FB_FakeEventSink;                // подменный журнал
END_VAR
