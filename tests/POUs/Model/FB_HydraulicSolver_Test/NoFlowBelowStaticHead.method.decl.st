// 55 %: H0·s² = 10,44 м меньше статического напора 10,6 м — подачи нет, напор статический, ток
// холостого хода 5,011 А.
METHOD PRIVATE NoFlowBelowStaticHead
VAR
    fbDut : FB_HydraulicSolver; // проверяемый ФБ
    stCfg : ST_SimCfg;          // характеристика насоса по умолчанию (stCfg.stPump)
END_VAR
