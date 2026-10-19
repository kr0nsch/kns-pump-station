// 04 §13.3, PMI-01, PMI-35: старт ПЛК — «задержка» tPlcStart = 10 с без запросов (событие 101009), затем первый
// шаг
METHOD PRIVATE PlcStartDelaysAllRequests
VAR
    fbDut  : FB_PowerRestore;           // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию: tPlcStart 10 с, tPwrRestart 10 с, tSeqStep 15 с
    fbSink : FB_FakeEventSink;          // подменный журнал
END_VAR
