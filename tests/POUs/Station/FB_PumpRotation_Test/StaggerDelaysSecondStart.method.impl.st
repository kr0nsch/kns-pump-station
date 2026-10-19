coUnit.TEST('Rotation_StaggerDelaysSecondStart_A5');

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
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 2,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequests, Message := 'first request at t0');
AssertTrue(Condition := fbDut.xStaggerWait, Message := 'stagger wait');
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 2,
      tStep := T#100MS, uiSteps := 49, xPlant := TRUE);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequests, Message := 'still one at t0 + 4.9 s');
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 2,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertEquals_UINT(Expected := 2, Actual := fbDut.uiRequests, Message := 'second exactly at t0 + 5 s');
AssertFalse(Condition := fbDut.xStaggerWait, Message := 'no wait any more');

coUnit.TEST_FINISHED();
