coUnit.TEST('Stepped_StartsLeadAtStartLevelAfterConfirm_A6_PMI02');

fbDut(xEnable := TRUE, rLevel_m := 1.6, xLevelValid := TRUE, itfTime := fbTime, stCfg := stCfg);   // t0
AssertTrue(Condition := fbDut.xConfirming, Message := 'confirmation running');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.6, xValid := TRUE, uiSteps := 49);   // t0 + 4,9 с
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiRequired, Message := 'no pump at t0 + 4.9 s');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.6, xValid := TRUE, uiSteps := 1);    // t0 + 5,0 с
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequired, Message := 'lead pump exactly at t0 + 5 s');
AssertEquals_REAL(Expected := 100.0, Actual := fbDut.rSpeed_pct, Delta := 0.0, Message := 'stepped speed 100 %');
AssertFalse(Condition := fbDut.xConfirming, Message := 'confirmation finished');

coUnit.TEST_FINISHED();
