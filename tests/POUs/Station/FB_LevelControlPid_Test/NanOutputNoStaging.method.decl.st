// Неконечный выход ПИД — подключение и отключение подпорного по выходу не срабатывают (сравнения с NaN ложны)
METHOD PRIVATE NanOutputNoStaging
VAR
    fbDut   : FB_LevelControlPid;           // ФБ под тестом
    fbTime  : PL.FB_FakeTime;               // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;                // уставки по умолчанию (04 §18.2)
    afbPump : ARRAY[1..3] OF FB_FakeMotorVfd;   // подменные насосы
    rNan    : REAL;                     // NaN
    uBits   : PL.U_RealBits;             // сборка NaN по битам
    fbDut2  : FB_LevelControlPid;          // второй экземпляр: два насоса
END_VAR
