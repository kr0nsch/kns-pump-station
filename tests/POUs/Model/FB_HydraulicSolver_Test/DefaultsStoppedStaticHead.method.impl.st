coUnit.TEST('HydraulicSolver_DefaultsStoppedStaticHead');

fbDut(rLevel_m := R_LEVEL_M, xIntakeDry := FALSE, stPump := stCfg.stPump);
// ref: hydraulic.stopped
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.rFlow_m3h, Delta := 0.0, Message := 'no flow');
AssertEquals_REAL(Expected := 10.6, Actual := fbDut.rHead_m, Delta := R_EPS_H, Message := 'static head');
AssertEquals_REAL(Expected := 1.1772, Actual := fbDut.rPressure_bar, Delta := R_EPS_P, Message := 'column pressure');
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.arCurrent_A[1], Delta := 0.0, Message := 'no current');

coUnit.TEST_FINISHED();
