// Снимок полного кольца после затирания (205 событий): 200 записей от старой (№ 6) к новой (№ 205) без
// разрыва на границе кольца
METHOD PRIVATE SnapshotAfterWrapOldestFirst
VAR_INST
    fbLog  : FB_EventLog;           // проверяемый журнал
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    stRec  : ST_EventRecord;        // запись снимка
    uiI    : UINT;                  // номер события и индекс снимка
    uiBad  : UINT;                  // записей снимка не на своём месте
END_VAR
