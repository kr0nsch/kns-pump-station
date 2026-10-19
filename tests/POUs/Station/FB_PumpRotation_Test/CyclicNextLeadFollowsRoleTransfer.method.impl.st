coUnit.TEST('Rotation_CyclicNextLeadFollowsRoleTransfer_A8_PMI10_PMI11');

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
stCfg.tMaxContRun := T#10M;
stRetain.uiNextLead := 1;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 10, xPlant := TRUE);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiLead, Message := 'cyclic: lead 1');
// передача роли Н1 → Н2 с перекрытием
afbPump[1].udiCurrentRunSeconds := 600;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 120, xPlant := TRUE);

AssertEquals_UINT(Expected := 2, Actual := fbDut.uiLead, Message := 'role passed to pump 2');
AssertFalse(Condition := fbDut.axRun[1], Message := 'pump 1 released');
AssertEquals_UINT(Expected := 3, Actual := stRetain.uiNextLead, Message := 'next lead after pump 2 is 3');
// останов и новый пуск: по кругу — Н3
afbPump[1].udiCurrentRunSeconds := 0;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 0,
      tStep := T#100MS, uiSteps := 2, xPlant := TRUE);
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertEquals_UINT(Expected := 3, Actual := fbDut.uiLead, Message := 'cyclic: next start pump 3');

coUnit.TEST_FINISHED();
