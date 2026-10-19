coUnit.TEST('Rotation_TieBreakStartsThenIndex_A8');

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

afbPump[1].udiRunSeconds := 100;
afbPump[2].udiRunSeconds := 100;
afbPump[3].udiRunSeconds := 100;
afbPump[1].udiStarts := 5;
afbPump[2].udiStarts := 3;
afbPump[3].udiStarts := 3;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertEquals_UINT(Expected := 2, Actual := fbDut.uiLead, Message := 'fewer starts, then lower index: pump 2');

coUnit.TEST_FINISHED();
