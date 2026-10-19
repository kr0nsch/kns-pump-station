coUnit.TEST('Protections_FirstCallDoesNotEnterFloatMode_A11_PMI01');

fbDut.itfEvents := fbSink;
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xFloatMode, Message := 'first call: no float mode');
AssertFalse(Condition := fbSink.Has(eFind := E_StationEvent.FloatModeOn), Message := 'first call: no event');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

AssertTrue(Condition := fbDut.xFloatMode, Message := 'second call: float mode on invalid level');

coUnit.TEST_FINISHED();
