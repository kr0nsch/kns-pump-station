// 04 §16, PMI-12: событие 101006 с номером насоса, получившего новый запрос в окне STN_ATS_WINDOW; замена позже
// окна — без события
METHOD PRIVATE EventNamesReplacementPump
VAR
    fbDut   : FB_Ats;                          // ФБ под тестом
    fbTime  : PL.FB_FakeTime;                  // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;                   // уставки по умолчанию (uiDutyMax = 2)
    afbPump : ARRAY[1..3] OF FB_FakeMotorVfd;  // подменные насосы: доступны, Auto
    fbSink  : FB_FakeEventSink;                // подменный журнал
    fbDut2  : FB_Ats;                          // второй экземпляр: замены нет
    uiStep  : UINT;                            // шаг 100 мс
END_VAR
