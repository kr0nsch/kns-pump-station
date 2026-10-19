// 04 §5.2 п. 3, §12, PMI-05, PMI-28: в ПИД при снятии роли по моточасам насос со связью с ПЧ снимается последним.
// Иначе остался бы насос без связи: ПИД потерял бы готовность и станция ушла бы в ступенчатое с KNS1.STEP, хотя
// работал насос со связью
METHOD PRIVATE StopKeepsCommPumpInPid
VAR
    fbDut    : FB_PumpRotation;                    // ФБ под тестом
    fbTime   : PL.FB_FakeTime;                     // подменное время, старт 1 ч
    stCfg    : ST_StationCfg;                      // уставки по умолчанию (RunHours, tStagger 5 с)
    stRetain : ST_StationRetain;                   // следующий ведущий (Cyclic)
    afbPump  : ARRAY[1..3] OF FB_FakeMotorVfd;     // подменные насосы: доступны, Auto, готовы, стоят
    fbSink   : FB_FakeEventSink;                   // подменный журнал
END_VAR
