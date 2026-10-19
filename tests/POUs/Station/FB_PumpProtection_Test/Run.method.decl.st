// Помощник: uiSteps шагов по 1 с; входы ФБ тест задаёт присваиванием
METHOD PRIVATE Run
VAR_IN_OUT
    fbDut  : FB_PumpProtection;         // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время
    stCfg  : ST_StationCfg;             // уставки
END_VAR
VAR_INPUT
    uiSteps : UINT;                     // шагов по 1 с
END_VAR
VAR
    uiStep : UINT;                      // номер шага
END_VAR
