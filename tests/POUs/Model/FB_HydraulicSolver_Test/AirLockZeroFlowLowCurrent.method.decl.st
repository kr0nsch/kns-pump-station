// Сухой ход насоса на 100 %: подача 0, ток 10,752 А — меньше порога недогрузки 12 А (PMI-15,
// DESIGN 11.3 ≈ 10,8 А).
METHOD PRIVATE AirLockZeroFlowLowCurrent
VAR
    fbDut : FB_HydraulicSolver; // проверяемый ФБ
    stCfg : ST_SimCfg;          // характеристика насоса по умолчанию (stCfg.stPump)
END_VAR
