coUnit.TEST('Rotation_CyclicStopsAssist_A5');

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

stCfg.eRotation := E_RotationMode.Cyclic;
afbPump[2].udiRunSeconds := 0;
afbPump[1].udiRunSeconds := 9000;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 2,
      tStep := T#100MS, uiSteps := 51, xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[1] AND fbDut.axRun[2] AND fbDut.uiLead = 1, Message := 'lead 1, assist 2');
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[1] AND NOT fbDut.axRun[2], Message := 'assist stopped, lead with more hours kept');

coUnit.TEST_FINISHED();
