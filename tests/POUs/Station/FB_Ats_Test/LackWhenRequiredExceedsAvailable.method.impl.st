coUnit.TEST('Ats_LackWhenRequiredExceedsAvailable_A9_PMI17');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.itfEvents := fbSink;
fbDut.xEnable := TRUE;
fbDut.uiAvailable := 3;

fbDut(uiRequired := 2, uiAvailable := 1, uiForeign := 0, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xLack, Message := 'required 2 > available 1: lack');
fbDut(uiRequired := 1, uiAvailable := 1, uiForeign := 0, itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xLack, Message := 'required 1 = available 1: no lack');

coUnit.TEST_FINISHED();
