coUnit.TEST('PowerRestore_SeqRemainCountsDown_A13_PMI34');

fbDut.itfEvents := fbSink;
fbDut.xPowerOk := TRUE;
fbDut.uiRequired := 2;
fbDut(itfTime := fbTime, stCfg := stCfg);

AssertEquals_UINT(Expected := 10, Actual := fbDut.uiSeqRemain_s, Message := '10 s at start');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

AssertEquals_UINT(Expected := 10, Actual := fbDut.uiSeqRemain_s, Message := '9.9 s rounds up to 10');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 9);

AssertEquals_UINT(Expected := 9, Actual := fbDut.uiSeqRemain_s, Message := '9 s');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 85);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiSeqRemain_s, Message := '0.5 s rounds up to 1');

coUnit.TEST_FINISHED();
