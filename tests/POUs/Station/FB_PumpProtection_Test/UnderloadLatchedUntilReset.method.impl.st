coUnit.TEST('PumpProtection_UnderloadLatchedUntilReset_A10_PMI15');

fbDut.xRunning := TRUE;
fbDut.rSpeedAct_pct := 100.0;
fbDut.rCurrent_A := 11.0;
fbDut.xCurrentValid := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, uiSteps := 15);

fbDut.xRunning := FALSE;
fbDut.rCurrent_A := 0.0;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, uiSteps := 600);

AssertTrue(Condition := fbDut.xUnderloadTrip, Message := 'latched until reset');

coUnit.TEST_FINISHED();
