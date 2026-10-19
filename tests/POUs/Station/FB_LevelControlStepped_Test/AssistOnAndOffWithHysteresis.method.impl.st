coUnit.TEST('Stepped_AssistOnAndOffWithHysteresis_A6_PMI03');

fbDut(xEnable := TRUE, rLevel_m := 2.5, xLevelValid := TRUE, xInit := TRUE, uiInitPumps := 1, itfTime := fbTime,
      stCfg := stCfg);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 2.5, xValid := TRUE, uiSteps := 50);
AssertEquals_UINT(Expected := 2, Actual := fbDut.uiRequired, Message := 'assist on at 2.4 m after 5 s');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 2.0, xValid := TRUE, uiSteps := 100);
AssertEquals_UINT(Expected := 2, Actual := fbDut.uiRequired, Message := 'hysteresis: two pumps at 2.0 m');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.3, xValid := TRUE, uiSteps := 50);
AssertEquals_UINT(Expected := 2, Actual := fbDut.uiRequired, Message := 'two pumps 4.9 s after crossing 1.4 m');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.3, xValid := TRUE, uiSteps := 1);
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequired, Message := 'assist off at 1.4 m after 5 s');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.2, xValid := TRUE, uiSteps := 100);
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequired, Message := 'lead keeps running above 1.0 m');

coUnit.TEST_FINISHED();
