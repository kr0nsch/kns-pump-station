// Неконечная скорость — насос не вращается: подача и ток 0, выходы конечны.
METHOD PRIVATE NonFiniteSpeedTreatedAsStopped
VAR
    fbDut : FB_HydraulicSolver; // проверяемый ФБ
    stCfg : ST_SimCfg;          // характеристика насоса по умолчанию (stCfg.stPump)
    uBits : PL.U_RealBits;
END_VAR
