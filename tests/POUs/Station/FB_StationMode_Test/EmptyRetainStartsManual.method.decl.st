// 04 §3.2: пустой retain (умолчания типа) — станция в «Ручном», способ «Ступенчатое»; первый вызов даёт импульс
// входа в «Ручной» без запросов насосам и без событий
METHOD PRIVATE EmptyRetainStartsManual
VAR
    fbDut    : FB_StationMode;                     // ФБ под тестом
    afbPump  : ARRAY[1..3] OF FB_FakeMotorVfd;     // подменные насосы
    fbSink   : FB_FakeEventSink;                   // подменный журнал
    stRetain : ST_StationRetain;                   // энергонезависимые данные станции
END_VAR
