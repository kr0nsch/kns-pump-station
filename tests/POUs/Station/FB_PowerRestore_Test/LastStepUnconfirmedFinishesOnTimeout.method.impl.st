coUnit.TEST('PowerRestore_LastStepUnconfirmedFinishesOnTimeout_A13');

fbDut.itfEvents := fbSink;
fbDut.xPowerOk := TRUE;
fbDut.uiRequired := 1;
fbDut(itfTime := fbTime, stCfg := stCfg);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 10);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 29);

AssertTrue(Condition := fbDut.xRestart, Message := 'step 1 at 29 s without confirmation');
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequestLimit, Message := 'limit 1 while waiting');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertFalse(Condition := fbDut.xRestart, Message := 'done after the start timeout');
AssertEquals_REAL(Expected := 1.0, Actual := fbSink.ValueOf(eFind := E_StationEvent.RestartDone), Delta := 0.0,
                  Message := 'event 101010 with 1');

coUnit.TEST_FINISHED();
