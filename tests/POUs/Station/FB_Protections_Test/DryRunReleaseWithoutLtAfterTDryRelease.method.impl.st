coUnit.TEST('Protections_DryRunReleaseWithoutLtAfterTDryRelease_A10_PMI19');

fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.5;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.xLevelValid := FALSE;
fbDut.xFloatDry := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

AssertTrue(Condition := fbDut.xDryRun AND fbDut.xFloatMode, Message := 'dry run by LS103 in float mode');
fbDut.xFloatDry := FALSE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 59);

AssertTrue(Condition := fbDut.xDryRun, Message := 'still dry 59 s after LS103 released');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertFalse(Condition := fbDut.xDryRun, Message := 'released 60 s after LS103 released');

coUnit.TEST_FINISHED();
