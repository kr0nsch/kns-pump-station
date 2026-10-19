// Условия по выходу ПИД действуют, только когда ПИД управляет: выход 100 % в слежении (ведущий не в
// SpeedAutoActive) подпорного не включает
METHOD PRIVATE OutputStagingOnlyWhenPidControls
VAR
    fbDut   : FB_LevelControlPid;           // ФБ под тестом
    fbTime  : PL.FB_FakeTime;               // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;                // уставки по умолчанию (04 §18.2)
    afbPump : ARRAY[1..3] OF FB_FakeMotorVfd;   // подменные насосы
END_VAR
