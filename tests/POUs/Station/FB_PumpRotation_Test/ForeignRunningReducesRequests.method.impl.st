coUnit.TEST('Rotation_ForeignRunningReducesRequests_A5_PMI31');

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

afbPump[1].eMode := PL.E_DeviceMode.Local;
afbPump[1].xRunning := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiForeign, Message := 'one foreign pump');
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiRequests, Message := 'required 1 - foreign 1 = no requests');
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRunning, Message := 'running counts the foreign pump');
AssertTrue(Condition := fbDut.aeRole[1] = E_PumpRole.None, Message := 'local pump has no role');
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 2,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequests, Message := 'required 2 - foreign 1 = one request');
AssertFalse(Condition := fbDut.axRun[1], Message := 'foreign pump not requested');

coUnit.TEST_FINISHED();
