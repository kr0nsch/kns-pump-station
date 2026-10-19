coUnit.TEST('Ats_NoReserveUsesEffectiveDuty_A5_A15_PMI32');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.itfEvents := fbSink;
fbDut.xEnable := TRUE;

stCfg.uiDutyMax := 3;
fbDut(uiRequired := 2, uiAvailable := 3, itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xNoReserve, Message := 'duty 3 capped to 2: three available have a reserve');
fbDut(uiRequired := 2, uiAvailable := 2, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xNoReserve, Message := 'two available: no reserve');
stCfg.uiDutyMax := 1;
fbDut(uiRequired := 1, uiAvailable := 2, itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xNoReserve, Message := 'duty 1: two available have a reserve');
fbDut(uiRequired := 1, uiAvailable := 1, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xNoReserve, Message := 'duty 1: one available, no reserve');

coUnit.TEST_FINISHED();
