// 04 §19.2: xSetManual старше xSetAuto в одном вызове (безопасный вариант); оба импульса — обработанные команды
METHOD PRIVATE ManualWinsOverAutoSameCall
VAR
    fbDut    : FB_StationMode;                     // ФБ под тестом
    afbPump  : ARRAY[1..3] OF FB_FakeMotorVfd;     // подменные насосы
    fbSink   : FB_FakeEventSink;                   // подменный журнал
    stRetain : ST_StationRetain;                   // энергонезависимые данные станции
END_VAR
