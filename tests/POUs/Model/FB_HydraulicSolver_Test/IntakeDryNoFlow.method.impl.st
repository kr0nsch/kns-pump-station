coUnit.TEST('HydraulicSolver_IntakeDryNoFlow');

fbDut.arSpeed[1] := 1.0;
fbDut(rLevel_m := 0.25, xIntakeDry := TRUE, stPump := stCfg.stPump);
// ref: hydraulic.intake_dry
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.rFlow_m3h, Delta := 0.0, Message := 'dry intake: no flow');
AssertEquals_REAL(Expected := 10.752, Actual := fbDut.arCurrent_A[1], Delta := R_EPS_I,
                  Message := 'dry intake current');
AssertEquals_REAL(Expected := 1.1772, Actual := fbDut.rPressure_bar, Delta := R_EPS_P, Message := 'column pressure');

coUnit.TEST_FINISHED();
