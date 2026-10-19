coUnit.TEST('Rotation_DisabledNoRequestsRolesStandby_A5');

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
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 10, xPlant := TRUE);

fbDut.xEnable := FALSE;
afbPump[3].xAvailable := FALSE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertEquals_UINT(Expected := 0, Actual := fbDut.uiRequests, Message := 'disabled: no requests');
AssertTrue(Condition := fbDut.aeRole[1] = E_PumpRole.Standby AND fbDut.aeRole[3] = E_PumpRole.None,
           Message := 'roles Standby / None');
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiLead, Message := 'no lead');

coUnit.TEST_FINISHED();
