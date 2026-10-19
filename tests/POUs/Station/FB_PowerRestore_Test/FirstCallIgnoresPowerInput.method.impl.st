coUnit.TEST('PowerRestore_FirstCallIgnoresPowerInput_A13_PMI01');

fbDut.itfEvents := fbSink;
fbDut(xPowerOk := FALSE, uiRequired := 1, itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xPowerLost, Message := 'first call: power not judged');
AssertFalse(Condition := fbSink.Has(eFind := E_StationEvent.PowerLost), Message := 'no false 101008');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertTrue(Condition := fbDut.xPowerLost, Message := 'second call: power lost');

coUnit.TEST_FINISHED();
