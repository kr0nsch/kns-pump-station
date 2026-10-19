// Помощник: uiSteps шагов времени tStep; входы ФБ тест задаёт присваиванием до вызова
METHOD PRIVATE Run
VAR_IN_OUT
    fbDut  : FB_Protections;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время
    stCfg  : ST_StationCfg;             // уставки
END_VAR
VAR_INPUT
    tStep   : TIME;                     // шаг времени
    uiSteps : UINT;                     // шагов
END_VAR
VAR
    uiStep : UINT;                      // номер шага
END_VAR
