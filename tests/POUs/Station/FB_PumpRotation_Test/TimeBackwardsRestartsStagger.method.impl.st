coUnit.TEST('Rotation_TimeBackwardsRestartsStagger_A5');

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
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 2,
      tStep := T#100MS, uiSteps := 10, xPlant := TRUE);

fbTime.SetNow(ltValue := LTIME#59M);
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 2,
      tStep := T#100MS, uiSteps := 50, xPlant := TRUE);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequests, Message := 'stagger restarted after time jump');
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 2,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertEquals_UINT(Expected := 2, Actual := fbDut.uiRequests, Message := 'second start after full interval');

coUnit.TEST_FINISHED();
