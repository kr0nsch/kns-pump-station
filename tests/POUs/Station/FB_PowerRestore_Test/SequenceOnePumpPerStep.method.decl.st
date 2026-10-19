// 04 §13.2, PMI-34: шаги по одному насосу — следующий через tSeqStep = 15 с после подтверждения пуска; конец —
// событие 101010 с числом пущенных
METHOD PRIVATE SequenceOnePumpPerStep
VAR
    fbDut  : FB_PowerRestore;           // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию: tPlcStart 10 с, tPwrRestart 10 с, tSeqStep 15 с
    fbSink : FB_FakeEventSink;          // подменный журнал
END_VAR
