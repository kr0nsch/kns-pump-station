coUnit.TEST('Rotation_RunningKeepRoles_A5');

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
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertEquals_UINT(Expected := 2, Actual := fbDut.uiLead, Message := 'pump 2 lead (0 h)');
afbPump[2].udiRunSeconds := 5000;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 100, xPlant := TRUE);

AssertEquals_UINT(Expected := 2, Actual := fbDut.uiLead, Message := 'running lead kept');
AssertFalse(Condition := fbDut.axRun[1] OR fbDut.axRun[3], Message := 'no extra start');

coUnit.TEST_FINISHED();
