coUnit.TEST('HydraulicSolver_NonFiniteSpeedTreatedAsStopped');

uBits.dwValue := DW_NAN;
fbDut.arSpeed[1] := uBits.rValue;
fbDut.arSpeed[2] := 1.0;
fbDut(rLevel_m := R_LEVEL_M, xIntakeDry := FALSE, stPump := stCfg.stPump);
AssertTrue(Condition := PL.F_IsFinite(rIn := fbDut.rFlow_m3h) AND PL.F_IsFinite(rIn := fbDut.rHead_m)
           AND PL.F_IsFinite(rIn := fbDut.arCurrent_A[1]) AND PL.F_IsFinite(rIn := fbDut.rPressure_bar),
           Message := 'outputs finite');
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.arFlow_m3h[1], Delta := 0.0, Message := 'NaN speed: no flow');
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.arCurrent_A[1], Delta := 0.0, Message := 'NaN speed: no current');
// ref: hydraulic.one_pump_100.q1_m3h — второй насос работает один
AssertEquals_REAL(Expected := 149.733973, Actual := fbDut.arFlow_m3h[2], Delta := R_EPS_Q,
                  Message := 'other pump alone');

coUnit.TEST_FINISHED();
