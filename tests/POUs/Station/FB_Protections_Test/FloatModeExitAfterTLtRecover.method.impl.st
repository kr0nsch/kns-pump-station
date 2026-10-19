coUnit.TEST('Protections_FloatModeExitAfterTLtRecover_A11_PMI27');

fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.5;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.xLevelValid := FALSE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 10);

fbDut.xLevelValid := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 29);

AssertTrue(Condition := fbDut.xFloatMode, Message := 'float mode before tLtRecover');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertFalse(Condition := fbDut.xFloatMode, Message := 'float mode left at tLtRecover');
AssertTrue(Condition := fbSink.Has(eFind := E_StationEvent.FloatModeOff), Message := 'event 101014');

coUnit.TEST_FINISHED();
