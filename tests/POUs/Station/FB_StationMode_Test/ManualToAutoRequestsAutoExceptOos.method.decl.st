// 04 §3.2, PMI-30: «Ручной» → «Автомат» — RequestMode(Auto) насосам в Manual и Local, OutOfService не трогается,
// насос в Auto — без запроса; событие 101001, импульс xEnteredAuto
METHOD PRIVATE ManualToAutoRequestsAutoExceptOos
VAR
    fbDut    : FB_StationMode;                     // ФБ под тестом
    afbPump  : ARRAY[1..3] OF FB_FakeMotorVfd;     // подменные насосы
    fbSink   : FB_FakeEventSink;                   // подменный журнал
    stRetain : ST_StationRetain;                   // энергонезависимые данные станции
END_VAR
