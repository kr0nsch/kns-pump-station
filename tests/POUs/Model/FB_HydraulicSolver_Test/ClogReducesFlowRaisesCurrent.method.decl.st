// Засор на 100 %: подача 75,01 м³/ч (было 149,73), ток 34,299 А = 1,3 · 26,384 — выше HH 34 А
// (PMI-15, DESIGN 11.3 ≈ 34,3 А).
METHOD PRIVATE ClogReducesFlowRaisesCurrent
VAR
    fbDut : FB_HydraulicSolver; // проверяемый ФБ
    stCfg : ST_SimCfg;          // характеристика насоса по умолчанию (stCfg.stPump)
END_VAR
