coUnit.TEST('Ats_NoReserveWhenOnePumpUnavailable_A9_A15_PMI32');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.itfEvents := fbSink;
fbDut.xEnable := TRUE;
fbDut.uiAvailable := 3;

fbDut(uiRequired := 1, uiAvailable := 2, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xNoReserve, Message := 'available 2 < 3: no reserve');
fbDut(uiRequired := 1, uiAvailable := 3, itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xNoReserve, Message := 'available 3: reserve ok');

coUnit.TEST_FINISHED();
