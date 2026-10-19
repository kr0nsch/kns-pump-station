coUnit.TEST('PlantModel_TimeBackwardsHoldsState');

stCmd.xInflowOverride := TRUE;
stCmd.rInflowOverride_m3h := 60.0;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
FOR uiI := 1 TO 10 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
rLevel := fbDut.stSts.rLevel_m;
fbTime.SetNow(ltValue := fbTime.Now() - LTIME#5S);
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertEquals_REAL(Expected := rLevel, Actual := fbDut.stSts.rLevel_m, Delta := 0.0, Message := 'level held');
AssertEquals_LREAL(Expected := 10.0, Actual := fbDut.stSts.lrSimTime_s, Delta := LREAL#1.0E-9,
                   Message := 'model time held');
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertEquals_LREAL(Expected := 11.0, Actual := fbDut.stSts.lrSimTime_s, Delta := LREAL#1.0E-9,
                   Message := 'model resumes');
AssertTrue(Condition := fbDut.stSts.rLevel_m > rLevel, Message := 'level rises again');

coUnit.TEST_FINISHED();
