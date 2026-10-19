coUnit.TEST('PumpProtection_CurrentAtThresholdIsNotUnderload_A10');

fbDut(xRunning := TRUE, rSpeedAct_pct := 100.0, rCurrent_A := 12.0, xCurrentValid := TRUE, itfTime := fbTime,
      stCfg := stCfg);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, uiSteps := 60);

AssertFalse(Condition := fbDut.xUnderloadTrip OR fbDut.xUnderloadTiming, Message := '12.0 A: no underload');

coUnit.TEST_FINISHED();
