// 04 §9.1, PMI-12 шаг 3: снятый АВР насос освобождается, когда снова доступен (сброшен, в Auto); KNS1.ATS
// снимается
METHOD PRIVATE AtsClearsWhenPumpAvailableAgain
VAR
    fbDut   : FB_Ats;                          // ФБ под тестом
    fbTime  : PL.FB_FakeTime;                  // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;                   // уставки по умолчанию (uiDutyMax = 2)
    afbPump : ARRAY[1..3] OF FB_FakeMotorVfd;  // подменные насосы: доступны, Auto
    fbSink  : FB_FakeEventSink;                // подменный журнал
END_VAR
