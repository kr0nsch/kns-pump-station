coUnit.TEST('Stepped_TwoToZeroAtStopLevel_A6');

fbDut(xEnable := TRUE, rLevel_m := 0.9, xLevelValid := TRUE, xInit := TRUE, uiInitPumps := 2, itfTime := fbTime,
      stCfg := stCfg);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 0.9, xValid := TRUE, uiSteps := 49);
AssertEquals_UINT(Expected := 2, Actual := fbDut.uiRequired, Message := 'two pumps at t0 + 4.9 s');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 0.9, xValid := TRUE, uiSteps := 1);
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiRequired, Message := 'two to zero at t0 + 5 s');

coUnit.TEST_FINISHED();
