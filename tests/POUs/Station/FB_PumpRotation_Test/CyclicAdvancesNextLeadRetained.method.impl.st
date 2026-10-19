coUnit.TEST('Rotation_CyclicAdvancesNextLeadRetained_A8_PMI10');

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
stRetain.uiNextLead := 2;
afbPump[2].udiRunSeconds := 9000;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertEquals_UINT(Expected := 2, Actual := fbDut.uiLead, Message := 'cyclic: pump 2 despite hours');
AssertEquals_UINT(Expected := 3, Actual := stRetain.uiNextLead, Message := 'next lead 3 retained');
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 0,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertEquals_UINT(Expected := 3, Actual := fbDut.uiLead, Message := 'cyclic: then pump 3');
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 0,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiLead, Message := 'cyclic: then pump 1');
AssertEquals_UINT(Expected := 2, Actual := stRetain.uiNextLead, Message := 'next lead 2 retained');

coUnit.TEST_FINISHED();
