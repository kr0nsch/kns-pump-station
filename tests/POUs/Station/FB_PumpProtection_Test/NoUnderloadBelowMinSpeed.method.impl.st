coUnit.TEST('PumpProtection_NoUnderloadBelowMinSpeed_A10');

fbDut.xRunning := TRUE;
fbDut.rSpeedAct_pct := 79.9;
fbDut.rCurrent_A := 5.0;
fbDut.xCurrentValid := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, uiSteps := 60);

AssertFalse(Condition := fbDut.xUnderloadTrip, Message := 'below 80 %: no underload');
fbDut2(xRunning := TRUE, rSpeedAct_pct := 80.0, rCurrent_A := 5.0, xCurrentValid := TRUE, itfTime := fbTime,
       stCfg := stCfg);
AssertTrue(Condition := fbDut2.xUnderloadTiming, Message := 'exactly 80 %: underload timing');

coUnit.TEST_FINISHED();
