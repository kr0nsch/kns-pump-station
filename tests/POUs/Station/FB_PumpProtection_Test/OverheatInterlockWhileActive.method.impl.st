coUnit.TEST('PumpProtection_OverheatInterlockWhileActive_A10_PMI16');

fbDut(xOverheat := TRUE, itfTime := fbTime, stCfg := stCfg);
AssertEquals_WORD(Expected := GVL_Const.KNS_ILK_OVERHEAT, Actual := fbDut.wInterlock, Message := 'overheat bit 2');
fbDut(xOverheat := FALSE, itfTime := fbTime, stCfg := stCfg);
AssertEquals_WORD(Expected := 0, Actual := fbDut.wInterlock, Message := 'no latch after overheat clears');

coUnit.TEST_FINISHED();
