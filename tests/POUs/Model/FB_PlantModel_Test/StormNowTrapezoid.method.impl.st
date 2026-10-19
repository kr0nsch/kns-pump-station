coUnit.TEST('PlantModel_StormNowTrapezoid');

stCfg.uiStormsPerDayMax := 0;
stCfg.rInflowAvg_m3h := 0.0;
stCmd.xStormNow := TRUE;
stCmd.rStormPeak_m3h := 200.0;
stCmd.tStormDuration := T#10M;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertFalse(Condition := stCmd.xStormNow, Message := 'pulse reset');
AssertTrue(Condition := fbDut.stSts.xStormActive, Message := 'storm started');
FOR uiI := 1 TO 45 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertEquals_REAL(Expected := 100.0, Actual := fbDut.stSts.rStormInflow_m3h, Delta := 0.01, Message := 'half of rise');
AssertEquals_REAL(Expected := 100.0, Actual := fbDut.stSts.rInflow_m3h, Delta := 0.01, Message := 'inflow = storm');
FOR uiI := 1 TO 45 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertEquals_REAL(Expected := 200.0, Actual := fbDut.stSts.rStormInflow_m3h, Delta := 0.01, Message := 'end of rise');
FOR uiI := 1 TO 210 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertEquals_REAL(Expected := 200.0, Actual := fbDut.stSts.rStormInflow_m3h, Delta := 0.01, Message := 'plateau');
FOR uiI := 1 TO 195 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertEquals_REAL(Expected := 100.0, Actual := fbDut.stSts.rStormInflow_m3h, Delta := 0.01, Message := 'half of fall');
FOR uiI := 1 TO 106 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.stSts.rStormInflow_m3h, Delta := 0.0, Message := 'storm over');
AssertFalse(Condition := fbDut.stSts.xStormActive, Message := 'storm ended');
stCmd.xInflowOverride := TRUE;
stCmd.xStormNow := TRUE;
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertFalse(Condition := stCmd.xStormNow OR fbDut.stSts.xStormActive, Message := 'ignored with inflow override');

coUnit.TEST_FINISHED();
