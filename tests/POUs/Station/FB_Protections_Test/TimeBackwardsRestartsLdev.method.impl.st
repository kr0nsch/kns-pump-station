coUnit.TEST('Protections_TimeBackwardsRestartsLdev_A10');

fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.5;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.xFloatDry := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 20);

fbTime.SetNow(ltValue := LTIME#59M);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 30);

AssertFalse(Condition := fbDut.xLs103Masked, Message := 'tLdev restarted after time jump');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertTrue(Condition := fbDut.xLs103Masked, Message := 'masked after full tLdev');

coUnit.TEST_FINISHED();
