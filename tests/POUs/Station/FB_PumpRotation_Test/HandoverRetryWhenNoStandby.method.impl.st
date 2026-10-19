coUnit.TEST('Rotation_HandoverRetryWhenNoStandby_A8_PMI11');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.axCommOk[1] := TRUE;
fbDut.axCommOk[2] := TRUE;
fbDut.axCommOk[3] := TRUE;
fbDut.itfEvents := fbSink;
fbDut.xEnable := TRUE;
fbDut.uiRequestLimit := 3;
fbDut.xHandoverAllowed := TRUE;

stCfg.tMaxContRun := T#10M;
afbPump[2].xAvailable := FALSE;
afbPump[3].xAvailable := FALSE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 10, xPlant := TRUE);

afbPump[1].udiCurrentRunSeconds := 600;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertFalse(Condition := fbDut.xHandover, Message := 'no standby: no handover');
afbPump[2].xAvailable := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#1S, uiSteps := 599, xPlant := TRUE);

AssertFalse(Condition := fbDut.axRun[2], Message := 'no retry before 10 min');
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#1S, uiSteps := 2, xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[2] AND fbDut.xHandover, Message := 'retry after 10 min');

coUnit.TEST_FINISHED();
