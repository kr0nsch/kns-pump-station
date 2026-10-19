// Помощник: uiSteps шагов по 100 мс — настоящий уровнемер PL.FB_AnalogInput (ток rIn_mA), затем FB_Protections
// с его выходами, как в PRG_Station (уровень, xValid, NE 107, уставки L, LL, H, HH)
METHOD PRIVATE RunWithAi
VAR_IN_OUT
    fbDut   : FB_Protections;           // ФБ под тестом
    fbTime  : PL.FB_FakeTime;           // подменное время
    stCfg   : ST_StationCfg;            // уставки станции
    fbAi    : PL.FB_AnalogInput;        // GVL_Devices.fbLT101
    stAiCmd : PL.ST_AnalogInputCmd;     // GVL_Hmi.stLT101Cmd
    stAiCfg : PL.ST_AnalogInputCfg;     // GVL_Persist.stLT101Cfg
END_VAR
VAR_INPUT
    rIn_mA  : REAL;                     // ток LT101
    uiSteps : UINT;                     // шагов по 100 мс
END_VAR
VAR
    uiStep : UINT;                      // номер шага
END_VAR
