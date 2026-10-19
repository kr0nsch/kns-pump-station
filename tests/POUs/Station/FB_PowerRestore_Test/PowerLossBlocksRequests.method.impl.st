coUnit.TEST('PowerRestore_PowerLossBlocksRequests_A13_PMI33');

fbDut.itfEvents := fbSink;
fbDut.xPowerOk := TRUE;
fbDut.uiRequired := 2;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.uiRequired := 0;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 11);

AssertEquals_UINT(Expected := 3, Actual := fbDut.uiRequestLimit, Message := 'sequence done: no limit');
fbDut.xPowerOk := FALSE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertTrue(Condition := fbDut.xPowerLost AND NOT fbDut.xRestart, Message := 'power lost');
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiRequestLimit, Message := 'no requests without power');
AssertTrue(Condition := fbSink.Has(eFind := E_StationEvent.PowerLost), Message := 'event 101008');

coUnit.TEST_FINISHED();
