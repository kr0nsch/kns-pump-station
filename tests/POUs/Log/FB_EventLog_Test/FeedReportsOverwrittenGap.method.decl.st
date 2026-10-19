// 250 событий: в кольце № 51…250; клиент, ждущий № 10, получает строки с № 51 и видит пропуск по номерам
METHOD PRIVATE FeedReportsOverwrittenGap
VAR_INST
    fbLog  : FB_EventLog;           // проверяемый журнал
    stFeed : ST_EventFeed;          // курсор клиента
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    uiI    : UINT;                  // номер события
END_VAR
