coUnit.TEST('Stepped_InvalidLevelHoldsState_A6_PMI25');

uBits.dwValue := 16#7FC00000;
rNan := uBits.rValue;
fbDut(xEnable := TRUE, rLevel_m := 0.0, xLevelValid := FALSE, xInit := TRUE, uiInitPumps := 1, itfTime := fbTime,
      stCfg := stCfg);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 0.0, xValid := FALSE, uiSteps := 600);
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequired, Message := 'invalid level: state held');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := rNan, xValid := TRUE, uiSteps := 600);
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequired, Message := 'NaN level: state held');
AssertFalse(Condition := fbDut.xConfirming, Message := 'no confirmation on NaN');

coUnit.TEST_FINISHED();
