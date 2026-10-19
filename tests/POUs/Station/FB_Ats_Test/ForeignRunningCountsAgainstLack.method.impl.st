coUnit.TEST('Ats_ForeignRunningCountsAgainstLack_A9_PMI31');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.itfEvents := fbSink;
fbDut.xEnable := TRUE;
fbDut.uiAvailable := 3;

fbDut(uiRequired := 2, uiAvailable := 1, uiForeign := 1, itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xLack, Message := 'available 1 + foreign 1 cover 2');

coUnit.TEST_FINISHED();
