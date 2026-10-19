// Насосы стоят: подачи и токи 0, напор — статический Hgeo − h = 10,6 м, давление — столб за обратными
// клапанами ρ·g·Hgeo = 1,1772 бар.
METHOD PRIVATE DefaultsStoppedStaticHead
VAR
    fbDut : FB_HydraulicSolver; // проверяемый ФБ
    stCfg : ST_SimCfg;          // характеристика насоса по умолчанию (stCfg.stPump)
END_VAR
