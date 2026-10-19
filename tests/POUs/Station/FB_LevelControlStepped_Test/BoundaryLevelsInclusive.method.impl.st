coUnit.TEST('Stepped_BoundaryLevelsInclusive_A6');

fbDut(xEnable := TRUE, rLevel_m := 2.4, xLevelValid := TRUE, xInit := TRUE, uiInitPumps := 1, itfTime := fbTime,
      stCfg := stCfg);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 2.4, xValid := TRUE, uiSteps := 50);
AssertEquals_UINT(Expected := 2, Actual := fbDut.uiRequired, Message := 'assist on exactly at 2.40 m');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.4, xValid := TRUE, uiSteps := 51);
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequired, Message := 'assist off exactly at 1.40 m');
fbDut2(xEnable := TRUE, rLevel_m := 1.59, xLevelValid := TRUE, itfTime := fbTime, stCfg := stCfg);
Run(fbDut := fbDut2, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.59, xValid := TRUE, uiSteps := 600);
AssertEquals_UINT(Expected := 0, Actual := fbDut2.uiRequired, Message := 'no start just below 1.60 m');

coUnit.TEST_FINISHED();
