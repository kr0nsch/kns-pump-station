coUnit.TEST('Stepped_TimeBackwardsRestartsConfirm_A6');

fbDut(xEnable := TRUE, rLevel_m := 1.7, xLevelValid := TRUE, itfTime := fbTime, stCfg := stCfg);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.7, xValid := TRUE, uiSteps := 30);
fbTime.SetNow(ltValue := LTIME#59M);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.7, xValid := TRUE, uiSteps := 50);
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiRequired, Message := 'confirmation restarted after time jump');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.7, xValid := TRUE, uiSteps := 1);
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequired, Message := 'start after full confirmation');

coUnit.TEST_FINISHED();
