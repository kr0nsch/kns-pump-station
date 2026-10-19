// 04 §13.3: старт ПЛК с «Автоматом» в retain — импульс xEnteredAuto в первом вызове (подхват работающих насосов)
// без запросов режима и без события
METHOD PRIVATE EnteredAutoPulsesOnFirstCallInAuto
VAR
    fbDut    : FB_StationMode;                     // ФБ под тестом
    afbPump  : ARRAY[1..3] OF FB_FakeMotorVfd;     // подменные насосы
    fbSink   : FB_FakeEventSink;                   // подменный журнал
    stRetain : ST_StationRetain;                   // энергонезависимые данные станции
END_VAR
