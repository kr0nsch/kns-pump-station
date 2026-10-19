coUnit.TEST('PlantModel_MassBalanceNoPumps');

stCmd.xInflowOverride := TRUE;
stCmd.rInflowOverride_m3h := 60.0;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
FOR uiI := 1 TO 600 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
// ref: tank.balance_60_10min.dlevel_m
AssertEquals_REAL(Expected := 2.033333, Actual := fbDut.stSts.rLevel_m, Delta := R_EPS_M,
                  Message := 'level after 10 min');
AssertEquals_REAL(Expected := 60.0, Actual := fbDut.stSts.rInflow_m3h, Delta := 0.0, Message := 'inflow');
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.stSts.rOutflow_m3h, Delta := 0.0, Message := 'no outflow');
AssertEquals_LREAL(Expected := 600.0, Actual := fbDut.stSts.lrSimTime_s, Delta := LREAL#1.0E-6,
                   Message := 'model time');

coUnit.TEST_FINISHED();
