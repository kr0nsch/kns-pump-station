coUnit.TEST('PowerRestore_PlcStartDelaysAllRequests_A13_PMI01_PMI35');

fbDut.itfEvents := fbSink;
fbDut.xPowerOk := TRUE;
fbDut.uiRequired := 2;
fbDut(itfTime := fbTime, stCfg := stCfg);

AssertTrue(Condition := fbDut.xRestart AND NOT fbDut.xPowerLost, Message := 'restart delay at PLC start');
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiRequestLimit, Message := 'no requests during tPlcStart');
AssertTrue(Condition := fbSink.Has(eFind := E_StationEvent.RestartBegin), Message := 'event 101009');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 9);

AssertEquals_UINT(Expected := 0, Actual := fbDut.uiRequestLimit, Message := 'still no requests at 9 s');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequestLimit, Message := 'first step at 10 s');

coUnit.TEST_FINISHED();
