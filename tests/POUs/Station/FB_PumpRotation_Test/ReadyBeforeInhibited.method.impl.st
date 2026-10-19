coUnit.TEST('Rotation_ReadyBeforeInhibited_A5');

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

afbPump[1].xReady := FALSE;
afbPump[2].udiRunSeconds := 500;
afbPump[3].udiRunSeconds := 900;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := FALSE);

AssertEquals_UINT(Expected := 2, Actual := fbDut.uiLead, Message := 'ready pump 2 before paused pump 1');
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 0,
      tStep := T#100MS, uiSteps := 1, xPlant := FALSE);

afbPump[2].xAvailable := FALSE;
afbPump[3].xAvailable := FALSE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 60, xPlant := FALSE);

AssertTrue(Condition := fbDut.axRun[1] AND fbDut.uiLead = 1, Message := 'no ready pump: paused pump 1 requested');

coUnit.TEST_FINISHED();
