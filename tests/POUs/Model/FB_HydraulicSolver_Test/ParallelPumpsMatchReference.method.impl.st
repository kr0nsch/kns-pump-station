coUnit.TEST('HydraulicSolver_ParallelPumpsMatchReference');

fbDut.arSpeed[1] := 0.75;
fbDut.arSpeed[2] := 0.75;
fbDut(rLevel_m := R_LEVEL_M, xIntakeDry := FALSE, stPump := stCfg.stPump);
// AssertEquals_REAL пропускает NaN (ABS(NaN) > Delta = FALSE): конечность проверяется отдельно
AssertTrue(Condition := PL.F_IsFinite(rIn := fbDut.rFlow_m3h) AND PL.F_IsFinite(rIn := fbDut.rHead_m)
           AND PL.F_IsFinite(rIn := fbDut.arCurrent_A[1]) AND PL.F_IsFinite(rIn := fbDut.arCurrent_A[2])
           AND PL.F_IsFinite(rIn := fbDut.rPressure_bar), Message := 'outputs finite');
// ref: hydraulic.two_pumps_75
AssertEquals_REAL(Expected := 120.004429, Actual := fbDut.rFlow_m3h, Delta := R_EPS_Q, Message := '2 x 75 %: flow');
AssertEquals_REAL(Expected := 60.002214, Actual := fbDut.arFlow_m3h[2], Delta := R_EPS_Q, Message := '2 x 75 %: each');
AssertEquals_REAL(Expected := 12.235445, Actual := fbDut.arCurrent_A[1], Delta := R_EPS_I,
                  Message := '2 x 75 %: current');
fbDut.arSpeed[1] := 1.0;
fbDut.arSpeed[2] := 1.0;
fbDut(rLevel_m := R_LEVEL_M, xIntakeDry := FALSE, stPump := stCfg.stPump);
// ref: hydraulic.two_pumps_100
AssertEquals_REAL(Expected := 197.697292, Actual := fbDut.rFlow_m3h, Delta := R_EPS_Q, Message := '2 x 100 %: flow');
fbDut.arSpeed[3] := 1.0;
fbDut(rLevel_m := 4.0, xIntakeDry := FALSE, stPump := stCfg.stPump);
// ref: hydraulic.three_pumps_100_at_4m
AssertEquals_REAL(Expected := 224.171462, Actual := fbDut.rFlow_m3h, Delta := R_EPS_Q,
                  Message := '3 x 100 % at 4 m: flow');
AssertEquals_REAL(Expected := 74.723821, Actual := fbDut.arFlow_m3h[3], Delta := R_EPS_Q, Message := '3 x 100 %: each');
AssertEquals_REAL(Expected := 31.116308, Actual := fbDut.rHead_m, Delta := R_EPS_H, Message := '3 x 100 %: head');
AssertEquals_REAL(Expected := 3.444910, Actual := fbDut.rPressure_bar, Delta := R_EPS_P,
                  Message := '3 x 100 %: pressure');

coUnit.TEST_FINISHED();
