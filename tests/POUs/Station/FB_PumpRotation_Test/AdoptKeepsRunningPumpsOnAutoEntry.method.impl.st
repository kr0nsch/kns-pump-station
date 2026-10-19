coUnit.TEST('Rotation_AdoptKeepsRunningPumpsOnAutoEntry_A3_PMI30');

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

fbDut.xEnable := FALSE;
afbPump[1].eMode := PL.E_DeviceMode.Manual;
afbPump[2].eMode := PL.E_DeviceMode.Manual;
afbPump[3].eMode := PL.E_DeviceMode.Manual;
afbPump[2].xRunning := TRUE;
afbPump[3].xRunning := TRUE;
afbPump[2].udiRunSeconds := 700;
afbPump[3].udiRunSeconds := 300;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 2,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertEquals_UINT(Expected := 0, Actual := fbDut.uiRequests, Message := 'Manual: no requests');
fbDut.xEnable := TRUE;
fbDut.xAdopt := TRUE;
fbDut.axAdoptRun[2] := TRUE;
fbDut.axAdoptRun[3] := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 2,
      tStep := T#100MS, uiSteps := 1, xPlant := FALSE);

AssertTrue(Condition := fbDut.axRun[2] AND fbDut.axRun[3] AND NOT fbDut.axRun[1], Message := 'running pumps adopted');
AssertEquals_UINT(Expected := 3, Actual := fbDut.uiLead, Message := 'lead: running pump with fewer hours');
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiForeign, Message := 'adopted pumps are not foreign');
fbDut.xAdopt := FALSE;
afbPump[1].eMode := PL.E_DeviceMode.Auto;
afbPump[2].eMode := PL.E_DeviceMode.Auto;
afbPump[3].eMode := PL.E_DeviceMode.Auto;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 2,
      tStep := T#100MS, uiSteps := 10, xPlant := FALSE);

AssertTrue(Condition := fbDut.axRun[2] AND fbDut.axRun[3], Message := 'requests kept after mode change');

coUnit.TEST_FINISHED();
