coUnit.TEST('Protections_MaskReleasedWhenFloatReturns_A10_PMI22');

fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.5;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.xFloatDry := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 30);

AssertTrue(Condition := fbDut.xLs103Masked, Message := 'masked');
fbDut.xFloatDry := FALSE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

AssertFalse(Condition := fbDut.xLs103Masked, Message := 'mask released when float returns');
AssertEquals_REAL(Expected := 103.0, Actual := fbSink.ValueOf(eFind := E_StationEvent.FloatUnmasked), Delta := 0.0,
                  Message := 'event 101012 with 103');

coUnit.TEST_FINISHED();
