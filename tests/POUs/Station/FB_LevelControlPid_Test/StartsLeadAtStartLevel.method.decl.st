// 04 §7.2, PMI-04: насосы стоят, уровень 1,60 м — пуск ведущего через tLvlConfirm = 5 с
METHOD PRIVATE StartsLeadAtStartLevel
VAR
    fbDut   : FB_LevelControlPid;           // ФБ под тестом
    fbTime  : PL.FB_FakeTime;               // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;                // уставки по умолчанию (04 §18.2)
    afbPump : ARRAY[1..3] OF FB_FakeMotorVfd;   // подменные насосы
END_VAR
