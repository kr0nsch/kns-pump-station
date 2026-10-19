// 04 §7.2, PMI-06: уровень 1,00 м дольше tLvlConfirm — все насосы стоп, в том числе из двух
METHOD PRIVATE StopAllAtStopLevel
VAR
    fbDut   : FB_LevelControlPid;           // ФБ под тестом
    fbTime  : PL.FB_FakeTime;               // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;                // уставки по умолчанию (04 §18.2)
    afbPump : ARRAY[1..3] OF FB_FakeMotorVfd;   // подменные насосы
END_VAR
