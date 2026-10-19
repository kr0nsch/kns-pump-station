coUnit.TEST('Rotation_AdoptAtPlcStartFromFeedback_A13_PMI35');

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

fbDut.uiRequestLimit := 0;
afbPump[1].xAvailable := FALSE;
afbPump[2].xAvailable := FALSE;
afbPump[3].xAvailable := FALSE;
fbDut.xAdopt := TRUE;
fbDut.axAdoptRun[1] := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := FALSE);

AssertTrue(Condition := fbDut.axRun[1] AND fbDut.uiLead = 1, Message := 'running pump adopted at PLC start');
fbDut.xAdopt := FALSE;
afbPump[1].xAvailable := TRUE;
afbPump[2].xAvailable := TRUE;
afbPump[3].xAvailable := TRUE;
afbPump[1].xRunning := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 10, xPlant := FALSE);

AssertTrue(Condition := fbDut.axRun[1], Message := 'request limit 0 does not stop adopted pump');
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRunningRequested, Message := 'running requested counted');

coUnit.TEST_FINISHED();
