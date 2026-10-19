coUnit.TEST('Protections_Ls103NotTrippedBelowOffMark_A10');

fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.5;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.rLevel_m := 0.1;
fbDut.xLevelL := TRUE;
fbDut.xLevelLL := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 30);

AssertTrue(Condition := fbDut.xLdev AND (fbDut.wLdev AND GVL_Const.STN_LDEV_LS103_MISSED) <> 0,
           Message := 'LDEV: LS103 missed');
AssertTrue(Condition := fbDut.xDryRun AND fbDut.xLevelUsable, Message := 'dry run by LL, LT trusted');

coUnit.TEST_FINISHED();
