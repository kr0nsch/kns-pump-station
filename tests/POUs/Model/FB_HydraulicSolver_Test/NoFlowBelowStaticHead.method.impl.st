coUnit.TEST('HydraulicSolver_NoFlowBelowStaticHead');

fbDut.arSpeed[1] := 0.55;
fbDut(rLevel_m := R_LEVEL_M, xIntakeDry := FALSE, stPump := stCfg.stPump);
// ref: hydraulic.below_static_55
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.rFlow_m3h, Delta := 0.0, Message := 'no flow below static head');
AssertEquals_REAL(Expected := 10.6, Actual := fbDut.rHead_m, Delta := R_EPS_H, Message := 'static head');
AssertEquals_REAL(Expected := 5.011314, Actual := fbDut.arCurrent_A[1], Delta := R_EPS_I, Message := 'no-load current');

coUnit.TEST_FINISHED();
