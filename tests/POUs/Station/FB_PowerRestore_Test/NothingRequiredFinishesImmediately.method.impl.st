coUnit.TEST('PowerRestore_NothingRequiredFinishesImmediately_A13');

fbDut.itfEvents := fbSink;
fbDut.xPowerOk := TRUE;
fbDut.uiRequired := 2;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.uiRequired := 0;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 10);

AssertFalse(Condition := fbDut.xRestart, Message := 'done right after the delay');
AssertEquals_UINT(Expected := 3, Actual := fbDut.uiRequestLimit, Message := 'no limit');
AssertEquals_REAL(Expected := 0.0, Actual := fbSink.ValueOf(eFind := E_StationEvent.RestartDone), Delta := 0.0,
                  Message := 'event 101010 with 0');

coUnit.TEST_FINISHED();
