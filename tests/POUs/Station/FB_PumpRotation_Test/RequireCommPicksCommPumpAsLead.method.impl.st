coUnit.TEST('Rotation_RequireCommPicksCommPumpAsLead_A5_A12_PMI28');

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

fbDut.xRequireComm := TRUE;
fbDut.axCommOk[1] := FALSE;
afbPump[2].udiRunSeconds := 500;
afbPump[3].udiRunSeconds := 900;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertEquals_UINT(Expected := 2, Actual := fbDut.uiLead, Message := 'lead with comm: pump 2');

coUnit.TEST_FINISHED();
