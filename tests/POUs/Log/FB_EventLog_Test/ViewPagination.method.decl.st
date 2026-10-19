// 45 записей по 20 строк: 3 страницы; страница 0 — № 45…26, страница 2 — № 5…1 и пустые строки; номер
// страницы больше последней ограничивается последней
METHOD PRIVATE ViewPagination
VAR_INST
    fbLog  : FB_EventLog;           // проверяемый журнал
    stView : ST_EventView;          // страница HMI
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    uiI    : UINT;                  // номер события
END_VAR
