coUnit.TEST('Protections_OorLtContradictingFloatMaskedAfterTLdev_A10_A11_PMI26');

fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.5;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.eLevelNe107 := PL.E_Ne107Status.OutOfSpecification;
fbDut.rLevel_m := 0.0;
fbDut.xLevelL := TRUE;
fbDut.xLevelLL := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

AssertTrue(Condition := fbDut.xDryRun, Message := 'LL of out-of-range LT: dry run');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 29);

AssertFalse(Condition := fbDut.xLtMasked, Message := 'LT101 not masked at tLdev - 1 s');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertTrue(Condition := fbDut.xLtMasked AND NOT fbDut.xLevelUsable, Message := 'LT101 masked after tLdev');
AssertTrue(Condition := (fbDut.wLdev AND GVL_Const.STN_LDEV_LT_MASKED) <> 0 AND fbDut.xLdev, Message := 'LDEV, LT bit');
AssertTrue(Condition := fbDut.xFloatMode AND fbSink.Has(eFind := E_StationEvent.FloatModeOn),
           Message := 'float mode, 101013');
AssertFalse(Condition := fbDut.xLs103Masked, Message := 'float not masked: LT is guilty');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 59);

AssertTrue(Condition := fbDut.xDryRun, Message := 'dry run held until tDryRelease');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 1);

AssertFalse(Condition := fbDut.xDryRun, Message := 'dry run released after tDryRelease without LS103');

coUnit.TEST_FINISHED();
