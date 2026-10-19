coUnit.TEST('Protections_FloatModeEntryWhilePumpingKeepsPumping_A11_PMI25');

fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.5;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.uiRunning := 1;
fbDut.xLevelValid := FALSE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

AssertTrue(Condition := fbDut.xFloatMode, Message := 'float mode');
AssertEquals_UINT(Expected := 3, Actual := fbDut.uiFloatRequired, Message := 'running pumps: pumping at once');

coUnit.TEST_FINISHED();
