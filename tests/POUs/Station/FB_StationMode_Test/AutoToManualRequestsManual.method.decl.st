// 04 §3.2: «Автомат» → «Ручной» — RequestMode(Manual) насосам в Auto и Local, OutOfService не трогается; событие
// 101002
METHOD PRIVATE AutoToManualRequestsManual
VAR
    fbDut    : FB_StationMode;                     // ФБ под тестом
    afbPump  : ARRAY[1..3] OF FB_FakeMotorVfd;     // подменные насосы
    fbSink   : FB_FakeEventSink;                   // подменный журнал
    stRetain : ST_StationRetain;                   // энергонезависимые данные станции
END_VAR
