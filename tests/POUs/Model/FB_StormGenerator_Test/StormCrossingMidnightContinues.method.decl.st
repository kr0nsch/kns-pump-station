// Ливень суток 21 (23,8694 ч, 2 385 650 мс, 175,0 м³/ч) не закончился к полуночи: в 00:15 суток 22
// приток — его полка 175,0 м³/ч.
METHOD PRIVATE StormCrossingMidnightContinues
VAR
    fbDut : FB_StormGenerator;  // проверяемый генератор
    stCfg : ST_SimCfg;          // параметры ливней по умолчанию
    uiK : UINT;
    xFound : BOOL;              // ливень суток 21 найден
END_VAR
