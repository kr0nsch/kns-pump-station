// Помощник: uiSteps шагов по 100 мс с одним уровнем и выходом ПИД (ПИД выбран, уровень достоверен)
METHOD PRIVATE Run
VAR_IN_OUT
    fbDut  : FB_LevelControlPid;        // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время
    stCfg  : ST_StationCfg;             // уставки
END_VAR
VAR_INPUT
    rLevel_m    : REAL;                 // уровень
    rPidOut_pct : REAL;                 // выход ПИД
    uiSteps     : UINT;                 // шагов по 100 мс
END_VAR
VAR
    uiStep : UINT;                      // номер шага
END_VAR
