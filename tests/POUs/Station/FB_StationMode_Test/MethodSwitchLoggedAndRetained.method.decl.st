// 04 §3.2, PMI-07: смена способа — в retain и в журнал (101004, 101003); xSetStepped старше xSetLevelPid; способ
// не зависит от режима станции
METHOD PRIVATE MethodSwitchLoggedAndRetained
VAR
    fbDut    : FB_StationMode;                     // ФБ под тестом
    afbPump  : ARRAY[1..3] OF FB_FakeMotorVfd;     // подменные насосы
    fbSink   : FB_FakeEventSink;                   // подменный журнал
    stRetain : ST_StationRetain;                   // энергонезависимые данные станции
END_VAR
