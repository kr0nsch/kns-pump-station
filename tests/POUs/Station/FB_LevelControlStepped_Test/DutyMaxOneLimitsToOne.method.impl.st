coUnit.TEST('Stepped_DutyMaxOneLimitsToOne_A6');

stCfg.uiDutyMax := 1;
fbDut(xEnable := TRUE, rLevel_m := 3.0, xLevelValid := TRUE, xInit := TRUE, uiInitPumps := 2, itfTime := fbTime,
      stCfg := stCfg);
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequired, Message := 'init limited to one');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 3.0, xValid := TRUE, uiSteps := 200);
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequired, Message := 'no assist with uiDutyMax = 1');

coUnit.TEST_FINISHED();
