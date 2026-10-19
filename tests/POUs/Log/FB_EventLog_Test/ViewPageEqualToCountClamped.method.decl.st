// Номер страницы, равный числу страниц (45 записей — страницы 0…2, запрошена 3), — последняя страница (№ 5…1),
// а не пустая страница за концом журнала
METHOD PRIVATE ViewPageEqualToCountClamped
VAR_INST
    fbLog  : FB_EventLog;           // проверяемый журнал
    stView : ST_EventView;          // страница HMI
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    uiI    : UINT;                  // номер события
END_VAR
