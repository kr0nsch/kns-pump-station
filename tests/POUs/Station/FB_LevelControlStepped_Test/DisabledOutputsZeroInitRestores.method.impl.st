coUnit.TEST('Stepped_DisabledOutputsZeroInitRestores_A6');

fbDut(xEnable := FALSE, rLevel_m := 1.2, xLevelValid := TRUE, xInit := TRUE, uiInitPumps := 1, itfTime := fbTime,
      stCfg := stCfg);
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiRequired, Message := 'disabled: zero');
fbDut(xEnable := TRUE, xInit := FALSE, itfTime := fbTime, stCfg := stCfg);
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequired, Message := 'enabled: state from init');
fbDut(xEnable := TRUE, xInit := TRUE, uiInitPumps := 0, itfTime := fbTime, stCfg := stCfg);
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiRequired, Message := 'next init: no running pumps');

coUnit.TEST_FINISHED();
