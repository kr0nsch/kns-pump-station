coUnit.TEST('PumpProtection_NoUnderloadWhenCurrentInvalid_A10_PMI29');

fbDut.xRunning := TRUE;
fbDut.rSpeedAct_pct := 100.0;
fbDut.rCurrent_A := 11.0;
fbDut.xCurrentValid := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.xCurrentValid := FALSE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, uiSteps := 60);

AssertFalse(Condition := fbDut.xUnderloadTrip, Message := 'invalid current: no underload');
uBits.dwValue := 16#7FC00000;
fbDut.xCurrentValid := TRUE;
fbDut.rCurrent_A := uBits.rValue;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, uiSteps := 60);

AssertFalse(Condition := fbDut.xUnderloadTrip, Message := 'NaN current: no underload');

coUnit.TEST_FINISHED();
