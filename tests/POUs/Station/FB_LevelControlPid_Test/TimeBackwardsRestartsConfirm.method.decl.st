// Время назад (сбой источника) — выдержка подтверждения пуска ведущего начинается заново, ложного пуска нет
METHOD PRIVATE TimeBackwardsRestartsConfirm
VAR
    fbDut   : FB_LevelControlPid;           // ФБ под тестом
    fbTime  : PL.FB_FakeTime;               // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;                // уставки по умолчанию (04 §18.2)
    afbPump : ARRAY[1..3] OF FB_FakeMotorVfd;   // подменные насосы
END_VAR
