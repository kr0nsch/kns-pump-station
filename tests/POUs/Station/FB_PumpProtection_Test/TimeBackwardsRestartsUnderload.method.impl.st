coUnit.TEST('PumpProtection_TimeBackwardsRestartsUnderload_A10');

fbDut.xRunning := TRUE;
fbDut.rSpeedAct_pct := 100.0;
fbDut.rCurrent_A := 11.0;
fbDut.xCurrentValid := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, uiSteps := 10);

fbTime.SetNow(ltValue := LTIME#59M);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, uiSteps := 15);

AssertFalse(Condition := fbDut.xUnderloadTrip, Message := 'tUnderload restarted after time jump');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, uiSteps := 1);

AssertTrue(Condition := fbDut.xUnderloadTrip, Message := 'trip after full tUnderload');

coUnit.TEST_FINISHED();
