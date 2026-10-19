coUnit.TEST('PlantModel_SetTimeOfDayKeepsDay');

stCfg.uiStormsPerDayMax := 0;
stCmd.xSetTimeOfDay := TRUE;
stCmd.rTimeOfDay_h := 23.99;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertFalse(Condition := stCmd.xSetTimeOfDay, Message := 'pulse reset');
AssertEquals_REAL(Expected := 23.99, Actual := fbDut.stSts.rTimeOfDay_h, Delta := 1.0E-4, Message := 'time of day set');
AssertEquals_UDINT(Expected := 0, Actual := fbDut.stSts.udiDay, Message := 'day 0');
FOR uiI := 1 TO 60 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertEquals_UDINT(Expected := 1, Actual := fbDut.stSts.udiDay, Message := 'next day after midnight');
AssertEquals_REAL(Expected := 0.006667, Actual := fbDut.stSts.rTimeOfDay_h, Delta := 1.0E-4, Message := '00:00:24');
stCmd.xSetTimeOfDay := TRUE;
stCmd.rTimeOfDay_h := 8.0;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertEquals_UDINT(Expected := 1, Actual := fbDut.stSts.udiDay, Message := 'day kept');
AssertEquals_REAL(Expected := 8.0, Actual := fbDut.stSts.rTimeOfDay_h, Delta := 1.0E-4, Message := '08:00');
// ref: inflow.profile.at_08h_m3h
AssertEquals_REAL(Expected := 112.0, Actual := fbDut.stSts.rInflow_m3h, Delta := 1.0E-3,
                  Message := 'profile inflow 112');

coUnit.TEST_FINISHED();
