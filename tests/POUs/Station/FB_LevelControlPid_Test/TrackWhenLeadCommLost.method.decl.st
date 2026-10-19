// 04 §12, PMI-28: у ведущего нет связи с ПЧ — ПИД в слежении (интегратор не копится против замершей частоты)
METHOD PRIVATE TrackWhenLeadCommLost
VAR
    fbDut   : FB_LevelControlPid;           // ФБ под тестом
    fbTime  : PL.FB_FakeTime;               // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;                // уставки по умолчанию (04 §18.2)
    afbPump : ARRAY[1..3] OF FB_FakeMotorVfd;   // подменные насосы
END_VAR
