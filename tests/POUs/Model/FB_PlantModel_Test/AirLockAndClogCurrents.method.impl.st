coUnit.TEST('PlantModel_AirLockAndClogCurrents');

stCmd.xInflowOverride := TRUE;
stCmd.rInflowOverride_m3h := 75.012261;
stFault.axAirLock[1] := TRUE;
stFault.axClog[2] := TRUE;
fbDut.axRun[1] := TRUE;
fbDut.auiFref[1] := UI_FREF_50HZ;
fbDut.axRun[2] := TRUE;
fbDut.auiFref[2] := UI_FREF_50HZ;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
FOR uiI := 1 TO 11 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
stCmd.xSetLevel := TRUE;
stCmd.rSetLevel_m := 1.4;
FOR uiI := 1 TO 3 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
// ref: hydraulic.air_lock_100, hydraulic.clog_100
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.stSts.arPumpFlow_m3h[1], Delta := 0.0,
                  Message := 'air lock: no flow');
AssertEquals_REAL(Expected := 10.752, Actual := fbDut.stSts.arCurrent_A[1], Delta := 0.01,
                  Message := 'air lock current');
AssertEquals_UINT(Expected := 108, Actual := fbDut.stIo.uiIT111, Message := 'air lock register');
AssertEquals_REAL(Expected := 75.012261, Actual := fbDut.stSts.arPumpFlow_m3h[2], Delta := 0.05,
                  Message := 'clog flow');
AssertEquals_REAL(Expected := 34.299021, Actual := fbDut.stSts.arCurrent_A[2], Delta := 0.01,
                  Message := 'clog current');
AssertEquals_UINT(Expected := 343, Actual := fbDut.stIo.uiIT121, Message := 'clog register');

coUnit.TEST_FINISHED();
