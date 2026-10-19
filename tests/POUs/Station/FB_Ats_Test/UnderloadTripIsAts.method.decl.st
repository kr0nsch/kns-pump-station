// 04 §9.1, PMI-15: фиксация недогрузки станцией (axTrip) у запрошенного насоса — АВР, даже пока устройство ещё
// доступно; снят, пока фиксация не сброшена
METHOD PRIVATE UnderloadTripIsAts
VAR
    fbDut   : FB_Ats;                          // ФБ под тестом
    fbTime  : PL.FB_FakeTime;                  // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;                   // уставки по умолчанию (uiDutyMax = 2)
    afbPump : ARRAY[1..3] OF FB_FakeMotorVfd;  // подменные насосы: доступны, Auto
    fbSink  : FB_FakeEventSink;                // подменный журнал
END_VAR
