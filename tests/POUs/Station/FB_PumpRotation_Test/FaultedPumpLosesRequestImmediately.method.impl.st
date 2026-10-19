coUnit.TEST('Rotation_FaultedPumpLosesRequestImmediately_A9_PMI12_PMI13');

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
      tStep := T#100MS, uiSteps := 100, xPlant := TRUE);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiLead, Message := 'lead 1 running');
afbPump[1].xFault := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := FALSE);

AssertFalse(Condition := fbDut.axRun[1], Message := 'faulted pump lost request');
AssertTrue(Condition := fbDut.aeRole[1] = E_PumpRole.None, Message := 'faulted pump role None');
AssertTrue(Condition := fbDut.axRun[2] AND fbDut.uiLead = 2, Message := 'replacement in the same call');

coUnit.TEST_FINISHED();
