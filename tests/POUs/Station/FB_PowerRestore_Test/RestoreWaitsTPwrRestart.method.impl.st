coUnit.TEST('PowerRestore_RestoreWaitsTPwrRestart_A13_PMI34');

fbDut.itfEvents := fbSink;
fbDut.xPowerOk := TRUE;
fbDut.uiRequired := 2;
fbDut(itfTime := fbTime, stCfg := stCfg);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 11);

fbDut.xPowerOk := FALSE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 5);

fbSink.Clear();
fbDut.xPowerOk := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertTrue(Condition := fbDut.xRestart AND NOT fbDut.xPowerLost, Message := 'restart delay after restore');
AssertTrue(Condition := fbSink.Has(eFind := E_StationEvent.RestartBegin), Message := 'event 101009');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 9);

AssertEquals_UINT(Expected := 0, Actual := fbDut.uiRequestLimit, Message := 'no requests at 9 s');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequestLimit, Message := 'first step at 10 s');

coUnit.TEST_FINISHED();
