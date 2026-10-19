coUnit.TEST('Protections_FloatModeStartsAllOnLs102StopsOnLs103_A11_PMI21_PMI25');

fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.5;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.xLevelValid := FALSE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

AssertTrue(Condition := fbDut.xFloatMode, Message := 'float mode');
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiFloatRequired, Message := 'waiting for LS102');
fbDut.xFloatHigh := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

AssertEquals_UINT(Expected := 3, Actual := fbDut.uiFloatRequired, Message := 'LS102: all pumps');
fbDut.xFloatHigh := FALSE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 100);

AssertEquals_UINT(Expected := 3, Actual := fbDut.uiFloatRequired, Message := 'pumping continues after LS102 released');
fbDut.xFloatDry := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

AssertEquals_UINT(Expected := 0, Actual := fbDut.uiFloatRequired, Message := 'LS103: all stop');

coUnit.TEST_FINISHED();
