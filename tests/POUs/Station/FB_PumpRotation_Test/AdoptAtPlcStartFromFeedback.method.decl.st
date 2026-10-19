// 04 §13.3, PMI-35: старт ПЛК — подхват по ОС (GVL_IO.xP10n_RFB) до первого вызова устройства; запрос не снимается
// ни недоступностью первого цикла, ни ограничением последовательного пуска
METHOD PRIVATE AdoptAtPlcStartFromFeedback
VAR
    fbDut    : FB_PumpRotation;                    // ФБ под тестом
    fbTime   : PL.FB_FakeTime;                     // подменное время, старт 1 ч
    stCfg    : ST_StationCfg;                      // уставки по умолчанию (RunHours, tStagger 5 с)
    stRetain : ST_StationRetain;                   // следующий ведущий (Cyclic)
    afbPump  : ARRAY[1..3] OF FB_FakeMotorVfd;     // подменные насосы: доступны, Auto, готовы, стоят
    fbSink   : FB_FakeEventSink;                   // подменный журнал
END_VAR
