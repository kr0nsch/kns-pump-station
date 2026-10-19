// Осушенный приёмок (уровень 0,25 м < 0,30 м): насос на 100 % не подаёт, ток холостого хода 10,752 А,
// давление — столб 1,1772 бар.
METHOD PRIVATE IntakeDryNoFlow
VAR
    fbDut : FB_HydraulicSolver; // проверяемый ФБ
    stCfg : ST_SimCfg;          // характеристика насоса по умолчанию (stCfg.stPump)
END_VAR
