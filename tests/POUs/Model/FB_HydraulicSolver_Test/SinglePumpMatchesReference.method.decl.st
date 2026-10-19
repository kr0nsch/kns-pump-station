// Один насос: 100 % — 149,73 м³/ч, 20,913 м, 26,384 А, 2,1889 бар; 60 % — 41,32 м³/ч, 7,742 А,
// 1,2542 бар (DESIGN 11.3: 150 и 41 м³/ч; ASSUMPTIONS T8: ≈ 1,25 бар на минимуме).
METHOD PRIVATE SinglePumpMatchesReference
VAR
    fbDut : FB_HydraulicSolver; // проверяемый ФБ
    stCfg : ST_SimCfg;          // характеристика насоса по умолчанию (stCfg.stPump)
END_VAR
