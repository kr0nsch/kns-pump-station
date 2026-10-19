// Время назад — окно STN_ATS_WINDOW отсчитывается заново, замена в окне называется в событии 101006
METHOD PRIVATE TimeBackwardsWindowRestarts
VAR
    fbDut   : FB_Ats;                          // ФБ под тестом
    fbTime  : PL.FB_FakeTime;                  // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;                   // уставки по умолчанию (uiDutyMax = 2)
    afbPump : ARRAY[1..3] OF FB_FakeMotorVfd;  // подменные насосы: доступны, Auto
    fbSink  : FB_FakeEventSink;                // подменный журнал
    uiStep  : UINT;                            // шаг 100 мс
END_VAR
