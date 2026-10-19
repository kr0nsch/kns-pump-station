coUnit.TEST('Protections_MaskReleasedWhenLtInvalid_A10_PMI25');

fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.5;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.xFloatDry := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 30);

AssertTrue(Condition := fbDut.xLs103Masked AND NOT fbDut.xDryRun, Message := 'masked, no dry run');
fbDut.xLevelValid := FALSE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

AssertFalse(Condition := fbDut.xLs103Masked, Message := 'mask released when LT101 invalid');
AssertTrue(Condition := fbDut.xDryRun, Message := 'tripped LS103 protects again');

coUnit.TEST_FINISHED();
