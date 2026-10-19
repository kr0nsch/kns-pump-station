coUnit.TEST('Stepped_StopsAllAtStopLevel_A6_PMI02');

fbDut(xEnable := TRUE, rLevel_m := 1.0, xLevelValid := TRUE, xInit := TRUE, uiInitPumps := 1, itfTime := fbTime,
      stCfg := stCfg);
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequired, Message := 'init: one pump');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.0, xValid := TRUE, uiSteps := 49);
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequired, Message := 'still running at t0 + 4.9 s');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.0, xValid := TRUE, uiSteps := 1);
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiRequired, Message := 'stop at t0 + 5 s');

coUnit.TEST_FINISHED();
