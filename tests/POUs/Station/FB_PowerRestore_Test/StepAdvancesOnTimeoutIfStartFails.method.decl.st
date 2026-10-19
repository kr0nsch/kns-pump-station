// 04 §13.2: пуск шага не подтвердился (АВР назначил замену) — следующий шаг через STN_SEQ_START_TIMEOUT = 30 с
METHOD PRIVATE StepAdvancesOnTimeoutIfStartFails
VAR
    fbDut  : FB_PowerRestore;           // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию: tPlcStart 10 с, tPwrRestart 10 с, tSeqStep 15 с
    fbSink : FB_FakeEventSink;          // подменный журнал
END_VAR
