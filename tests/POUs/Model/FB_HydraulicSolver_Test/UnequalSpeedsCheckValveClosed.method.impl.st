coUnit.TEST('HydraulicSolver_UnequalSpeedsCheckValveClosed');

fbDut.arSpeed[1] := 1.0;
fbDut.arSpeed[2] := 0.6;
fbDut(rLevel_m := R_LEVEL_M, xIntakeDry := FALSE, stPump := stCfg.stPump);
// ref: hydraulic.unequal_100_60
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.arFlow_m3h[2], Delta := 0.0,
                  Message := 'slow pump: check valve closed');
AssertEquals_REAL(Expected := 149.733973, Actual := fbDut.arFlow_m3h[1], Delta := R_EPS_Q,
                  Message := 'fast pump alone');
AssertEquals_REAL(Expected := 5.548032, Actual := fbDut.arCurrent_A[2], Delta := R_EPS_I,
                  Message := 'closed valve current');
fbDut.arSpeed[2] := 0.9;
fbDut(rLevel_m := R_LEVEL_M, xIntakeDry := FALSE, stPump := stCfg.stPump);
// AssertEquals_REAL пропускает NaN (ABS(NaN) > Delta = FALSE): конечность проверяется отдельно
AssertTrue(Condition := PL.F_IsFinite(rIn := fbDut.rFlow_m3h) AND PL.F_IsFinite(rIn := fbDut.rHead_m)
           AND PL.F_IsFinite(rIn := fbDut.arCurrent_A[1]) AND PL.F_IsFinite(rIn := fbDut.arCurrent_A[2])
           AND PL.F_IsFinite(rIn := fbDut.rPressure_bar), Message := 'outputs finite');
// ref: hydraulic.unequal_100_90
AssertEquals_REAL(Expected := 120.4555, Actual := fbDut.arFlow_m3h[1], Delta := R_EPS_Q, Message := '100 % pump');
AssertEquals_REAL(Expected := 60.767556, Actual := fbDut.arFlow_m3h[2], Delta := R_EPS_Q, Message := '90 % pump');
AssertEquals_REAL(Expected := 25.707226, Actual := fbDut.rHead_m, Delta := R_EPS_H, Message := 'common head');
AssertEquals_REAL(Expected := 16.531532, Actual := fbDut.arCurrent_A[2], Delta := R_EPS_I, Message := '90 % current');

coUnit.TEST_FINISHED();
