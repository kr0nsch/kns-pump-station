coUnit.TEST('Rotation_HandoverAfterTMaxContRunWithOverlap_A8_PMI11');

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

stCfg.tMaxContRun := T#10M;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 10, xPlant := TRUE);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiLead, Message := 'lead 1 running');
afbPump[1].udiCurrentRunSeconds := 600;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[2] AND fbDut.xHandover, Message := 'replacement pump 2 requested');
AssertTrue(Condition := fbDut.aeRole[2] = E_PumpRole.Assist, Message := 'replacement is assist during overlap');
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 100, xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[1] AND fbDut.axRun[2], Message := 'overlap: both requested at 10.0 s');
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertTrue(Condition := NOT fbDut.axRun[1] AND fbDut.axRun[2] AND NOT fbDut.xHandover, Message := 'old pump released');
AssertEquals_UINT(Expected := 2, Actual := fbDut.uiLead, Message := 'role passed to pump 2');
AssertEquals_REAL(Expected := 2.0, Actual := fbSink.ValueOf(eFind := E_StationEvent.ContRunHandover), Delta := 0.0,
                  Message := 'event 101007 with pump 2');

coUnit.TEST_FINISHED();
