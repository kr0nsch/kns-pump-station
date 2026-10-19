// Параллельная работа: два по 75 % — 120,00 м³/ч (по 60,00); два по 100 % — 197,70; три по 100 % на
// 4,0 м — 224,17 м³/ч, напор 31,116 м (DESIGN 11.3, ASSUMPTIONS T9).
METHOD PRIVATE ParallelPumpsMatchReference
VAR
    fbDut : FB_HydraulicSolver; // проверяемый ФБ
    stCfg : ST_SimCfg;          // характеристика насоса по умолчанию (stCfg.stPump)
END_VAR
