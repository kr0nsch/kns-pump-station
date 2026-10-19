// API 2.2, PMI-31: у насоса в Local запрос режима меняет запомненный дистанционный режим, сам режим остаётся Local
METHOD PRIVATE LocalPumpGetsRememberedMode
VAR
    fbDut    : FB_StationMode;                     // ФБ под тестом
    afbPump  : ARRAY[1..3] OF FB_FakeMotorVfd;     // подменные насосы
    fbSink   : FB_FakeEventSink;                   // подменный журнал
    stRetain : ST_StationRetain;                   // энергонезависимые данные станции
END_VAR
