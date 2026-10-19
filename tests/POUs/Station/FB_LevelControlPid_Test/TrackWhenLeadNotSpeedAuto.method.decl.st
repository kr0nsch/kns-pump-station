// 04 §7.3, PMI-04: ведущий работает, но не в SpeedAutoActive — ПИД в слежении за его заданием; ведущего нет —
// слежение за 0
METHOD PRIVATE TrackWhenLeadNotSpeedAuto
VAR
    fbDut   : FB_LevelControlPid;           // ФБ под тестом
    fbTime  : PL.FB_FakeTime;               // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;                // уставки по умолчанию (04 §18.2)
    afbPump : ARRAY[1..3] OF FB_FakeMotorVfd;   // подменные насосы
END_VAR
