coUnit.TEST('Protections_DryRunByLtLl_A10_PMI18');

fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.5;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.rLevel_m := 0.45;
fbDut.xLevelL := TRUE;
fbDut.xLevelLL := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

AssertTrue(Condition := fbDut.xDryRun, Message := 'LT101 LL: dry run');

coUnit.TEST_FINISHED();
