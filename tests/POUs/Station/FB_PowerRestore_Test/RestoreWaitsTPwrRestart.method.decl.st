// 04 §13.2, PMI-34: напряжение вернулось — «задержка» tPwrRestart = 10 с (событие 101009), затем первый шаг
METHOD PRIVATE RestoreWaitsTPwrRestart
VAR
    fbDut  : FB_PowerRestore;           // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию: tPlcStart 10 с, tPwrRestart 10 с, tSeqStep 15 с
    fbSink : FB_FakeEventSink;          // подменный журнал
END_VAR
