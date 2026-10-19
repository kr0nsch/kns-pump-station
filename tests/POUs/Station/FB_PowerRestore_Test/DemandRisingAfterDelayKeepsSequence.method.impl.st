coUnit.TEST('PowerRestore_DemandRisingAfterDelayKeepsSequence_A13_PMI34');

fbDut.itfEvents := fbSink;
fbDut.xPowerOk := TRUE;
fbDut.uiRequired := 1;
fbDut(itfTime := fbTime, stCfg := stCfg);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 10);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequestLimit, Message := 'step 1 at 10 s');
AssertTrue(Condition := fbDut.xRestart, Message := 'not done before the lead start is confirmed');
AssertFalse(Condition := fbSink.Has(eFind := E_StationEvent.RestartDone), Message := 'no 101010 yet');
fbDut.uiRequired := 2;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

fbDut.uiRunningRequested := 1;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 15);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequestLimit, Message := 'step 1 until tSeqStep after confirmation');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertEquals_UINT(Expected := 2, Actual := fbDut.uiRequestLimit, Message := 'step 2 after tSeqStep');
AssertTrue(Condition := fbDut.xRestart, Message := 'not done before the assist start is confirmed');
fbDut.uiRunningRequested := 2;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertFalse(Condition := fbDut.xRestart, Message := 'done after both starts');
AssertEquals_UINT(Expected := 3, Actual := fbDut.uiRequestLimit, Message := 'no limit');
AssertEquals_REAL(Expected := 2.0, Actual := fbSink.ValueOf(eFind := E_StationEvent.RestartDone), Delta := 0.0,
                  Message := 'event 101010 with 2');

coUnit.TEST_FINISHED();
