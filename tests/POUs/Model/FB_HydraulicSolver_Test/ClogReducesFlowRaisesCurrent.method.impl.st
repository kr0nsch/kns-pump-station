coUnit.TEST('HydraulicSolver_ClogReducesFlowRaisesCurrent');

fbDut.arSpeed[1] := 1.0;
fbDut.axClog[1] := TRUE;
fbDut(rLevel_m := R_LEVEL_M, xIntakeDry := FALSE, stPump := stCfg.stPump);
// AssertEquals_REAL пропускает NaN (ABS(NaN) > Delta = FALSE): конечность проверяется отдельно
AssertTrue(Condition := PL.F_IsFinite(rIn := fbDut.rFlow_m3h) AND PL.F_IsFinite(rIn := fbDut.rHead_m)
           AND PL.F_IsFinite(rIn := fbDut.arCurrent_A[1]) AND PL.F_IsFinite(rIn := fbDut.arCurrent_A[2])
           AND PL.F_IsFinite(rIn := fbDut.rPressure_bar), Message := 'outputs finite');
// ref: hydraulic.clog_100
AssertEquals_REAL(Expected := 75.012261, Actual := fbDut.arFlow_m3h[1], Delta := R_EPS_Q, Message := 'clog: flow');
AssertEquals_REAL(Expected := 13.188346, Actual := fbDut.rHead_m, Delta := R_EPS_H, Message := 'clog: head');
AssertEquals_REAL(Expected := 34.299021, Actual := fbDut.arCurrent_A[1], Delta := R_EPS_I, Message := 'clog: current');
AssertTrue(Condition := fbDut.arCurrent_A[1] > R_IT_HH_A, Message := 'above HH 34 A');

coUnit.TEST_FINISHED();
