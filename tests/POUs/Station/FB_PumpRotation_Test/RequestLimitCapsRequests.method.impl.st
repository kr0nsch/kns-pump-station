coUnit.TEST('Rotation_RequestLimitCapsRequests_A13_PMI34');

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

fbDut.uiRequestLimit := 1;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 2,
      tStep := T#100MS, uiSteps := 100, xPlant := TRUE);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequests, Message := 'limit 1: one request');
fbDut.uiRequestLimit := 2;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 2,
      tStep := T#100MS, uiSteps := 100, xPlant := TRUE);

AssertEquals_UINT(Expected := 2, Actual := fbDut.uiRequests, Message := 'limit 2: two requests');
fbDut.uiRequestLimit := 0;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 2,
      tStep := T#100MS, uiSteps := 10, xPlant := TRUE);

AssertEquals_UINT(Expected := 2, Actual := fbDut.uiRequests, Message := 'limit does not stop running requested pumps');

coUnit.TEST_FINISHED();
