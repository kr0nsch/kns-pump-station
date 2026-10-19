coUnit.TEST('Protections_GoodLtContradictingFloatMasksFloat_A10_PMI22');

fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.5;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.rLevel_m := 1.2;
fbDut.xFloatDry := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#1S, uiSteps := 30);

AssertTrue(Condition := fbDut.xLs103Masked AND NOT fbDut.xLtMasked AND fbDut.xLevelUsable,
           Message := 'Good LT: float masked, LT kept');
AssertFalse(Condition := fbDut.xFloatMode, Message := 'no float mode');

coUnit.TEST_FINISHED();
