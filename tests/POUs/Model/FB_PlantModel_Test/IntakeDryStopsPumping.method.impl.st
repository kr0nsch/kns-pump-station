coUnit.TEST('PlantModel_IntakeDryStopsPumping');

stCmd.xInflowOverride := TRUE;
stCmd.rInflowOverride_m3h := 0.0;
stCmd.xSetLevel := TRUE;
stCmd.rSetLevel_m := 0.25;
fbDut.axRun[1] := TRUE;
fbDut.auiFref[1] := UI_FREF_50HZ;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
FOR uiI := 1 TO 12 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
// ref: hydraulic.intake_dry
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.stSts.rOutflow_m3h, Delta := 0.0, Message := 'no pumping');
AssertEquals_REAL(Expected := 0.25, Actual := fbDut.stSts.rLevel_m, Delta := R_EPS_M, Message := 'level kept');
AssertEquals_REAL(Expected := 10.752, Actual := fbDut.stSts.arCurrent_A[1], Delta := 0.01,
                  Message := 'dry running current');

coUnit.TEST_FINISHED();
