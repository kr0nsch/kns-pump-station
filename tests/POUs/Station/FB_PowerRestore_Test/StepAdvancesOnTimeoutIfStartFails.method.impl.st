coUnit.TEST('PowerRestore_StepAdvancesOnTimeoutIfStartFails_A13');

fbDut.itfEvents := fbSink;
fbDut.xPowerOk := TRUE;
fbDut.uiRequired := 2;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.uiRequired := 3;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 10);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 29);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequestLimit, Message := 'step 1 at 29 s without confirmation');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertEquals_UINT(Expected := 2, Actual := fbDut.uiRequestLimit, Message := 'step 2 after timeout');

coUnit.TEST_FINISHED();
