coUnit.TEST('Rotation_StopMoreHoursWhenFewerNeeded_A5_PMI03');

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
afbPump[2].udiRunSeconds := 500;
afbPump[3].udiRunSeconds := 900;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 2,
      tStep := T#100MS, uiSteps := 51, xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[1] AND fbDut.axRun[2] AND fbDut.uiLead = 1, Message := 'lead 1, assist 2');
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[1] AND NOT fbDut.axRun[2], Message := 'more hours pump 2 stopped');
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 2,
      tStep := T#100MS, uiSteps := 60, xPlant := TRUE);

afbPump[1].udiRunSeconds := 800;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[2] AND NOT fbDut.axRun[1], Message := 'lead with more hours stopped');
AssertEquals_UINT(Expected := 2, Actual := fbDut.uiLead, Message := 'remaining pump is lead');
AssertEquals_REAL(Expected := 2.0, Actual := fbSink.ValueOf(eFind := E_StationEvent.LeadChanged), Delta := 0.0,
                  Message := 'event 101005 with pump 2');

coUnit.TEST_FINISHED();
