coUnit.TEST('Rotation_EmergencyRequiresAllThree_A10_PMI20');

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
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 3,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 3,
      tStep := T#100MS, uiSteps := 100, xPlant := TRUE);

AssertEquals_UINT(Expected := 3, Actual := fbDut.uiRequests, Message := 'three requests after two stagger intervals');
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 3,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertTrue(Condition := fbDut.aeRole[1] = E_PumpRole.Lead AND fbDut.aeRole[2] = E_PumpRole.Assist
           AND fbDut.aeRole[3] = E_PumpRole.Assist, Message := 'roles Lead, Assist, Assist');
AssertEquals_UINT(Expected := 3, Actual := fbDut.uiRunningRequested, Message := 'all running');

coUnit.TEST_FINISHED();
