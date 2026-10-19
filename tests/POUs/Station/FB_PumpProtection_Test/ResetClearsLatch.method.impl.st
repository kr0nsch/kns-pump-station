coUnit.TEST('PumpProtection_ResetClearsLatch_A10_PMI15');

fbDut.xRunning := TRUE;
fbDut.rSpeedAct_pct := 100.0;
fbDut.rCurrent_A := 11.0;
fbDut.xCurrentValid := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, uiSteps := 15);

fbDut(xReset := TRUE, itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xUnderloadTrip, Message := 'reset clears latch');
AssertEquals_WORD(Expected := 0, Actual := fbDut.wInterlock, Message := 'interlock cleared');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, uiSteps := 14);

AssertFalse(Condition := fbDut.xUnderloadTrip, Message := 'underload counted again from reset');

coUnit.TEST_FINISHED();
