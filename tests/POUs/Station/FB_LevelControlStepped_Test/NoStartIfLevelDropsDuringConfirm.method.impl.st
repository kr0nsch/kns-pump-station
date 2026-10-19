coUnit.TEST('Stepped_NoStartIfLevelDropsDuringConfirm_A6');

fbDut(xEnable := TRUE, rLevel_m := 1.7, xLevelValid := TRUE, itfTime := fbTime, stCfg := stCfg);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.7, xValid := TRUE, uiSteps := 30);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.5, xValid := TRUE, uiSteps := 10);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.7, xValid := TRUE, uiSteps := 50);
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiRequired, Message := 'confirmation restarted after the dip');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.7, xValid := TRUE, uiSteps := 1);
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequired, Message := 'start 5 s after the new crossing');

coUnit.TEST_FINISHED();
