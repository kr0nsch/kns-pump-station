coUnit.TEST('Protections_FalseLs103MaskedAfterTLdev_A10_PMI22');

fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.5;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.xFloatDry := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

AssertTrue(Condition := fbDut.xDryRun, Message := 'false LS103 stops pumps first');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 29);

AssertFalse(Condition := fbDut.xLs103Masked, Message := 'not masked before tLdev');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertTrue(Condition := fbDut.xLs103Masked AND fbDut.xLdev, Message := 'masked after tLdev, LDEV');
AssertTrue(Condition := (fbDut.wLdev AND GVL_Const.STN_LDEV_LS103_FALSE) <> 0, Message := 'LDEV bit LS103 false');
AssertFalse(Condition := fbDut.xDryRun OR fbDut.xLtMasked, Message := 'dry run released, LT101 trusted');
AssertEquals_REAL(Expected := 103.0, Actual := fbSink.ValueOf(eFind := E_StationEvent.FloatMasked), Delta := 0.0,
                  Message := 'event 101011 with 103');

coUnit.TEST_FINISHED();
