coUnit.TEST('Rotation_RunHoursPicksLeastHours_A8_PMI09');

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

afbPump[1].udiRunSeconds := 300;
afbPump[2].udiRunSeconds := 100;
afbPump[3].udiRunSeconds := 200;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[2] AND NOT fbDut.axRun[1] AND NOT fbDut.axRun[3],
           Message := 'least hours pump 2 requested');
AssertEquals_UINT(Expected := 2, Actual := fbDut.uiLead, Message := 'pump 2 is lead');
AssertTrue(Condition := fbDut.aeRole[2] = E_PumpRole.Lead AND fbDut.aeRole[1] = E_PumpRole.Standby
           AND fbDut.aeRole[3] = E_PumpRole.Standby, Message := 'roles Lead and Standby');
AssertEquals_REAL(Expected := 2.0, Actual := fbSink.ValueOf(eFind := E_StationEvent.LeadChanged), Delta := 0.0,
                  Message := 'event 101005 with pump 2');

coUnit.TEST_FINISHED();
