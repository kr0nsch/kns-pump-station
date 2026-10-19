coUnit.TEST('PumpProtection_UnderloadTripsAfterTUnderload_A10_PMI15');

fbDut.xRunning := TRUE;
fbDut.rSpeedAct_pct := 100.0;
fbDut.rCurrent_A := 11.0;
fbDut.xCurrentValid := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);

AssertTrue(Condition := fbDut.xUnderloadTiming, Message := 'underload timing');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, uiSteps := 14);

AssertFalse(Condition := fbDut.xUnderloadTrip, Message := 'no trip at 14 s');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, uiSteps := 1);

AssertTrue(Condition := fbDut.xUnderloadTrip, Message := 'trip at 15 s');
AssertEquals_WORD(Expected := GVL_Const.KNS_ILK_UNDERLOAD, Actual := fbDut.wInterlock, Message := 'interlock bit 1');

coUnit.TEST_FINISHED();
