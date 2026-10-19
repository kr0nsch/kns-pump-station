coUnit.TEST('PumpProtection_DisabledWhenThresholdZero_A10');

stCfg.rUnderload_A := 0.0;

fbDut.xRunning := TRUE;
fbDut.rSpeedAct_pct := 100.0;
fbDut.rCurrent_A := 11.0;
fbDut.xCurrentValid := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, uiSteps := 60);

AssertFalse(Condition := fbDut.xUnderloadTrip OR fbDut.xUnderloadTiming, Message := 'threshold 0: disabled');

coUnit.TEST_FINISHED();
