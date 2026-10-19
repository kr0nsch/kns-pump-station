coUnit.TEST('PowerRestore_PowerLossDuringSequenceRestarts_A13_PMI34');

fbDut.itfEvents := fbSink;
fbDut.xPowerOk := TRUE;
fbDut.uiRequired := 2;
fbDut(itfTime := fbTime, stCfg := stCfg);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 10);

fbDut.uiRunningRequested := 1;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 16);
fbDut.uiRunningRequested := 2;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertEquals_UINT(Expected := 3, Actual := fbDut.uiRequestLimit, Message := 'sequence done');
fbDut.uiRequired := 3;
fbDut.xPowerOk := FALSE;
fbDut.uiRunningRequested := 0;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 2);

fbDut.xPowerOk := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 11);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequestLimit, Message := 'restarted from step 1');
fbDut.xPowerOk := FALSE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

fbDut.xPowerOk := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 10);

AssertEquals_UINT(Expected := 0, Actual := fbDut.uiRequestLimit, Message := 'loss during sequence: delay again');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequestLimit, Message := 'step 1 again');

coUnit.TEST_FINISHED();
