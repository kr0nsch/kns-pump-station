// Clear (xResetPlant) снимает идущий ливень и внеочередной ливень; ливни, которые начнутся позже
// (сутки 1, 4,80 ч), идут.
METHOD PRIVATE ClearSuppressesRunningStorms
VAR
    fbDut : FB_StormGenerator;  // проверяемый генератор
    stCfg : ST_SimCfg;          // параметры ливней по умолчанию
END_VAR
