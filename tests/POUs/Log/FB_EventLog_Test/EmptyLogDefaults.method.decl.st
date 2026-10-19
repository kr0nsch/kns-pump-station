// Пустой журнал: записей 0, GetRecord — FALSE, одна пустая страница, курсор без строк (первая = последняя + 1)
METHOD PRIVATE EmptyLogDefaults
VAR_INST
    fbLog  : FB_EventLog;           // проверяемый журнал
    stView : ST_EventView;          // страница HMI
    stFeed : ST_EventFeed;          // курсор клиента
END_VAR
VAR
    stRec : ST_EventRecord;         // запись
END_VAR
