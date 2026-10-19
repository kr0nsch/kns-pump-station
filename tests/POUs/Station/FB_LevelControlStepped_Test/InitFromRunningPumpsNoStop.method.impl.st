coUnit.TEST('Stepped_InitFromRunningPumpsNoStop_A6_PMI07');

fbDut(xEnable := TRUE, rLevel_m := 1.2, xLevelValid := TRUE, xInit := TRUE, uiInitPumps := 1, itfTime := fbTime,
      stCfg := stCfg);
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequired, Message := 'one pump right after init');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.2, xValid := TRUE, uiSteps := 600);
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequired, Message := 'running pump kept between stop and start');

coUnit.TEST_FINISHED();
