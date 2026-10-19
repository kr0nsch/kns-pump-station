// 04 §7.4, PMI-29: нет насоса со связью — ни среди работающих, ни среди доступных стоящих — ПИД не готов
METHOD PRIVATE NotReadyWithoutCommPump
VAR
    fbDut   : FB_LevelControlPid;           // ФБ под тестом
    fbTime  : PL.FB_FakeTime;               // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;                // уставки по умолчанию (04 §18.2)
    afbPump : ARRAY[1..3] OF FB_FakeMotorVfd;   // подменные насосы
END_VAR
