coUnit.TEST('PlantModel_SteadyStateOnePump87');

stCmd.xInflowOverride := TRUE;
stCmd.rInflowOverride_m3h := 120.0;
fbDut.axRun[1] := TRUE;
fbDut.auiFref[1] := UI_FREF_87PCT;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
FOR uiI := 1 TO 15 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
// ref: steady.one_pump_87_inflow_120.level_m
stCmd.xSetLevel := TRUE;
stCmd.rSetLevel_m := 1.23735;
FOR uiI := 1 TO 600 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertEquals_REAL(Expected := 43.5, Actual := fbDut.stSts.arFreq_Hz[1], Delta := 1.0E-3, Message := 'drive at 43.5 Hz');
// AssertEquals_REAL пропускает NaN: конечность проверяется отдельно
AssertTrue(Condition := PL.F_IsFinite(rIn := fbDut.stSts.rLevel_m) AND PL.F_IsFinite(rIn := fbDut.stSts.rOutflow_m3h)
           AND PL.F_IsFinite(rIn := fbDut.stIo.rPT201_mA) AND PL.F_IsFinite(rIn := fbDut.stSts.arCurrent_A[1]),
           Message := 'outputs finite');
// ref: steady.one_pump_87_inflow_120.*
AssertEquals_REAL(Expected := 1.23735, Actual := fbDut.stSts.rLevel_m, Delta := 2.0E-3,
                  Message := 'equilibrium level kept');
AssertEquals_REAL(Expected := 120.0, Actual := fbDut.stSts.rOutflow_m3h, Delta := 0.05, Message := 'outflow = inflow');
AssertEquals_REAL(Expected := 6.923223, Actual := fbDut.stIo.rPT201_mA, Delta := R_EPS_MA, Message := 'PT201 mA');
AssertEquals_REAL(Expected := 7.84, Actual := fbDut.stIo.rFT202_mA, Delta := R_EPS_MA, Message := 'FT202 mA');
AssertEquals_REAL(Expected := 19.290206, Actual := fbDut.stSts.arCurrent_A[1], Delta := 0.01,
                  Message := 'motor current');
AssertTrue(Condition := fbDut.stIo.uiIT111 >= 192 AND fbDut.stIo.uiIT111 <= 194, Message := 'current register 193');
AssertTrue(Condition := fbDut.stIo.xP101_RFB, Message := 'run relay');

coUnit.TEST_FINISHED();
