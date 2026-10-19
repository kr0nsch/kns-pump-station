coUnit.TEST('Protections_DryRunReleaseAboveL_A10_PMI18');

fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.5;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.rLevel_m := 0.45;
fbDut.xLevelL := TRUE;
fbDut.xLevelLL := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

fbDut.rLevel_m := 0.7;
fbDut.xLevelLL := FALSE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 10);

AssertTrue(Condition := fbDut.xDryRun, Message := 'between LL and L: still dry run');
fbDut.rLevel_m := 0.9;
fbDut.xLevelL := FALSE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

AssertFalse(Condition := fbDut.xDryRun, Message := 'above L: released');

coUnit.TEST_FINISHED();
