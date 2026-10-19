coUnit.TEST('HydraulicSolver_AirLockZeroFlowLowCurrent');

fbDut.arSpeed[1] := 1.0;
fbDut.axAirLock[1] := TRUE;
fbDut(rLevel_m := R_LEVEL_M, xIntakeDry := FALSE, stPump := stCfg.stPump);
// ref: hydraulic.air_lock_100
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.arFlow_m3h[1], Delta := 0.0, Message := 'air lock: no flow');
AssertEquals_REAL(Expected := 10.752, Actual := fbDut.arCurrent_A[1], Delta := R_EPS_I, Message := 'air lock current');
AssertTrue(Condition := fbDut.arCurrent_A[1] < R_UNDERLOAD_A, Message := 'below underload threshold');

coUnit.TEST_FINISHED();
