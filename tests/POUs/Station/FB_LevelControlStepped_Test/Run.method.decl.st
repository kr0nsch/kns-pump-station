// Помощник: uiSteps шагов по 100 мс с одним уровнем; в каждом шаге — сначала время, потом вызов
METHOD PRIVATE Run
VAR_IN_OUT
    fbDut  : FB_LevelControlStepped;    // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время
    stCfg  : ST_StationCfg;             // уставки
END_VAR
VAR_INPUT
    rLevel_m : REAL;                    // уровень
    xValid   : BOOL;                    // уровень достоверен
    uiSteps  : UINT;                    // шагов по 100 мс
END_VAR
VAR
    uiStep : UINT;                      // номер шага
END_VAR
