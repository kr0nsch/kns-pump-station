coUnit.TEST('Protections_FalseLs102MaskedAfterTLdev_A10_PMI23');

fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.5;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.rLevel_m := 2.0;
fbDut.xFloatHigh := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

AssertTrue(Condition := fbDut.xEmergency, Message := 'false LS102 starts emergency first');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 29);

AssertFalse(Condition := fbDut.xLs102Masked, Message := 'not masked at tLdev - 1 s');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertTrue(Condition := fbDut.xLs102Masked AND fbDut.xLdev, Message := 'masked after tLdev');
AssertFalse(Condition := fbDut.xEmergency, Message := 'emergency released below H');
AssertEquals_REAL(Expected := 102.0, Actual := fbSink.ValueOf(eFind := E_StationEvent.FloatMasked), Delta := 0.0,
                  Message := 'event 101011 with 102');

coUnit.TEST_FINISHED();
