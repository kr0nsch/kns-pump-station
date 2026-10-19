coUnit.TEST('Protections_LtMaskReleasedAfterTLtRecover_A10_A11_PMI27');

fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.5;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.eLevelNe107 := PL.E_Ne107Status.OutOfSpecification;
fbDut.rLevel_m := 0.0;
fbDut.xLevelL := TRUE;
fbDut.xLevelLL := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 30);

AssertTrue(Condition := fbDut.xLtMasked, Message := 'LT masked');
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut.rLevel_m := 1.2;
fbDut.xLevelL := FALSE;
fbDut.xLevelLL := FALSE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 29);

AssertTrue(Condition := fbDut.xLtMasked, Message := 'still masked before tLtRecover');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertFalse(Condition := fbDut.xLtMasked, Message := 'mask released after tLtRecover');
AssertTrue(Condition := fbDut.xLevelUsable AND fbDut.xFloatMode, Message := 'usable, float mode until recovery');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 30);

AssertFalse(Condition := fbDut.xFloatMode, Message := 'float mode left after tLtRecover');
AssertTrue(Condition := fbSink.Has(eFind := E_StationEvent.FloatModeOff), Message := 'event 101014');

coUnit.TEST_FINISHED();
