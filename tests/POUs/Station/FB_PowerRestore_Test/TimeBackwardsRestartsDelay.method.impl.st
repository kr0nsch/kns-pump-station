coUnit.TEST('PowerRestore_TimeBackwardsRestartsDelay_A13');

fbDut.itfEvents := fbSink;
fbDut.xPowerOk := TRUE;
fbDut.uiRequired := 2;
fbDut(itfTime := fbTime, stCfg := stCfg);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 5);

fbTime.SetNow(ltValue := LTIME#59M);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 10);

AssertEquals_UINT(Expected := 0, Actual := fbDut.uiRequestLimit, Message := 'delay restarted after time jump');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequestLimit, Message := 'first step after full delay');

coUnit.TEST_FINISHED();
