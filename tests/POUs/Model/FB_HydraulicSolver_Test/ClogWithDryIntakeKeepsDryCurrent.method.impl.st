coUnit.TEST('HydraulicSolver_ClogWithDryIntakeKeepsDryCurrent');

fbDut.arSpeed[1] := 1.0;
fbDut.axClog[1] := TRUE;
fbDut(rLevel_m := 0.25, xIntakeDry := TRUE, stPump := stCfg.stPump);
// AssertEquals_REAL пропускает NaN: конечность проверяется отдельно
AssertTrue(Condition := PL.F_IsFinite(rIn := fbDut.arCurrent_A[1]), Message := 'current finite');
// ref: hydraulic.intake_dry
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.rFlow_m3h, Delta := 0.0, Message := 'dry intake: no flow');
AssertEquals_REAL(Expected := 10.752, Actual := fbDut.arCurrent_A[1], Delta := R_EPS_I,
                  Message := 'clogged pump, dry intake: dry current');
AssertTrue(Condition := fbDut.arCurrent_A[1] < R_UNDERLOAD_A, Message := 'below underload threshold');
fbDut.axAirLock[1] := TRUE;
fbDut(rLevel_m := R_LEVEL_M, xIntakeDry := FALSE, stPump := stCfg.stPump);
// ref: hydraulic.air_lock_100
AssertEquals_REAL(Expected := 10.752, Actual := fbDut.arCurrent_A[1], Delta := R_EPS_I,
                  Message := 'clogged pump, air lock: dry current');

coUnit.TEST_FINISHED();
