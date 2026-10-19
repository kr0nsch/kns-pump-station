coUnit.TEST('PlantModel_ResetPlantClearsOverflowTime');

stCmd.xInflowOverride := TRUE;
stCmd.rInflowOverride_m3h := 250.0;
stCmd.xSetLevel := TRUE;
stCmd.rSetLevel_m := 4.55;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
FOR uiI := 1 TO 60 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertTrue(Condition := fbDut.stSts.udiOverflow_s > 0, Message := 'overflow counted');
stCmd.rInflowOverride_m3h := 0.0;
stCmd.xResetPlant := TRUE;
fbTime.Advance(tStep := T_STEP);
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertEquals_REAL(Expected := 1.2, Actual := fbDut.stSts.rLevel_m, Delta := R_EPS_M, Message := 'level 1.2 m');
AssertEquals_UDINT(Expected := 0, Actual := fbDut.stSts.udiOverflow_s, Message := 'overflow time cleared');

coUnit.TEST_FINISHED();
