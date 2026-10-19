// uiStormsPerDayMax = 10 ограничивается SIM_STORMS_MAX = 4 (эталон: по 4 ливня в сутки 0…2).
METHOD PRIVATE CountLimitedToMax
VAR
    fbDut : FB_StormGenerator;  // проверяемый генератор
    stCfg : ST_SimCfg;          // параметры ливней по умолчанию
END_VAR
