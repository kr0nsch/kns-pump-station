coUnit.TEST('Rotation_HandoverDisabledInEmergency_A8');

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

stCfg.tMaxContRun := T#10M;
fbDut.xHandoverAllowed := FALSE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 10, xPlant := TRUE);

afbPump[1].udiCurrentRunSeconds := 6000;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 100, xPlant := TRUE);

AssertFalse(Condition := fbDut.xHandover OR fbDut.axRun[2] OR fbDut.axRun[3], Message := 'not allowed: no handover');
stCfg0.tMaxContRun := T#0S;
fbDut2.aitfPump[1] := afbPump[1];
fbDut2.aitfPump[2] := afbPump[2];
fbDut2.aitfPump[3] := afbPump[3];
fbDut2.xEnable := TRUE;
fbDut2.uiRequestLimit := 3;
fbDut2.xHandoverAllowed := TRUE;
fbDut2(uiRequired := 1, itfTime := fbTime, stCfg := stCfg0, stRetain := stRetain);
fbDut2(uiRequired := 1, itfTime := fbTime, stCfg := stCfg0, stRetain := stRetain);
AssertFalse(Condition := fbDut2.xHandover, Message := 'tMaxContRun = 0: disabled');

coUnit.TEST_FINISHED();
