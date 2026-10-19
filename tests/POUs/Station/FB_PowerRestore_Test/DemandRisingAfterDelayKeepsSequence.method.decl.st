// 04 §13.2, PMI-34: после задержки потребность растёт (ступенчатый автомат после Restart начинает с нуля и
// подтверждает второй насос позже конца задержки) — последовательность не завершается, пока не пущены все
// запрошенные: подпорный — через tSeqStep после подтверждения ведущего, событие 101010 со значением 2
METHOD PRIVATE DemandRisingAfterDelayKeepsSequence
VAR
    fbDut  : FB_PowerRestore;           // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию: tPlcStart 10 с, tPwrRestart 10 с, tSeqStep 15 с
    fbSink : FB_FakeEventSink;          // подменный журнал
END_VAR
