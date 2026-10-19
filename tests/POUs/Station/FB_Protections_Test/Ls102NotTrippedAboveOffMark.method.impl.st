coUnit.TEST('Protections_Ls102NotTrippedAboveOffMark_A10_PMI24');

fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.5;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.rLevel_m := 4.5;
fbDut.xLevelH := TRUE;
fbDut.xLevelHH := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 29);

AssertFalse(Condition := fbDut.xLdev, Message := 'no LDEV before tLdev');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertTrue(Condition := fbDut.xLdev AND (fbDut.wLdev AND GVL_Const.STN_LDEV_LS102_MISSED) <> 0,
           Message := 'LDEV: LS102 missed');
AssertTrue(Condition := fbDut.xEmergency AND NOT fbDut.xLs102Masked, Message := 'emergency by HH, no mask');

coUnit.TEST_FINISHED();
