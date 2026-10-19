coUnit.TEST('HydraulicSolver_SinglePumpMatchesReference');

fbDut.arSpeed[1] := 1.0;
fbDut(rLevel_m := R_LEVEL_M, xIntakeDry := FALSE, stPump := stCfg.stPump);
// AssertEquals_REAL пропускает NaN (ABS(NaN) > Delta = FALSE): конечность проверяется отдельно
AssertTrue(Condition := PL.F_IsFinite(rIn := fbDut.rFlow_m3h) AND PL.F_IsFinite(rIn := fbDut.rHead_m)
           AND PL.F_IsFinite(rIn := fbDut.arCurrent_A[1]) AND PL.F_IsFinite(rIn := fbDut.arCurrent_A[2])
           AND PL.F_IsFinite(rIn := fbDut.rPressure_bar), Message := 'outputs finite');
// ref: hydraulic.one_pump_100
AssertEquals_REAL(Expected := 149.733973, Actual := fbDut.arFlow_m3h[1], Delta := R_EPS_Q, Message := '100 %: flow');
AssertEquals_REAL(Expected := 20.913321, Actual := fbDut.rHead_m, Delta := R_EPS_H, Message := '100 %: head');
AssertEquals_REAL(Expected := 26.383863, Actual := fbDut.arCurrent_A[1], Delta := R_EPS_I, Message := '100 %: current');
AssertEquals_REAL(Expected := 2.188937, Actual := fbDut.rPressure_bar, Delta := R_EPS_P, Message := '100 %: pressure');
fbDut.arSpeed[1] := 0.6;
fbDut(rLevel_m := R_LEVEL_M, xIntakeDry := FALSE, stPump := stCfg.stPump);
// ref: hydraulic.one_pump_60
AssertEquals_REAL(Expected := 41.319694, Actual := fbDut.rFlow_m3h, Delta := R_EPS_Q, Message := '60 %: flow');
AssertEquals_REAL(Expected := 7.741741, Actual := fbDut.arCurrent_A[1], Delta := R_EPS_I, Message := '60 %: current');
AssertEquals_REAL(Expected := 1.254244, Actual := fbDut.rPressure_bar, Delta := R_EPS_P, Message := '60 %: pressure');

coUnit.TEST_FINISHED();
