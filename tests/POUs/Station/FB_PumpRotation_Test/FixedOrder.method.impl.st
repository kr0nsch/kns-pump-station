coUnit.TEST('Rotation_FixedOrder_A8');

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

stCfg.eRotation := E_RotationMode.Fixed;
afbPump[1].udiRunSeconds := 9000;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiLead, Message := 'fixed: pump 1 first');
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 2,
      tStep := T#100MS, uiSteps := 50, xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[2] AND fbDut.aeRole[2] = E_PumpRole.Assist, Message := 'fixed: pump 2 assist');
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 0,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

afbPump[1].eMode := PL.E_DeviceMode.OutOfService;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 60, xPlant := TRUE);

AssertEquals_UINT(Expected := 2, Actual := fbDut.uiLead, Message := 'fixed: pump 1 unavailable, pump 2 next');

coUnit.TEST_FINISHED();
