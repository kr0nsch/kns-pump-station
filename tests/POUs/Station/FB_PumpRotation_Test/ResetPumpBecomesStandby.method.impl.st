coUnit.TEST('Rotation_ResetPumpBecomesStandby_A9_PMI12');

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

afbPump[1].xFault := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 100, xPlant := TRUE);

afbPump[1].xFault := FALSE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 100, xPlant := TRUE);

AssertTrue(Condition := fbDut.aeRole[1] = E_PumpRole.Standby AND NOT fbDut.axRun[1],
           Message := 'reset pump is standby');
AssertTrue(Condition := fbDut.axRun[2] AND fbDut.uiLead = 2, Message := 'replacement keeps running');

coUnit.TEST_FINISHED();
