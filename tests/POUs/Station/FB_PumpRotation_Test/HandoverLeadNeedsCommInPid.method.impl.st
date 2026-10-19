coUnit.TEST('Rotation_HandoverLeadNeedsCommInPid_A5_A8_A12_PMI11');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.axCommOk[1] := TRUE;
fbDut.axCommOk[2] := FALSE;
fbDut.axCommOk[3] := TRUE;
fbDut.itfEvents := fbSink;
fbDut.xEnable := TRUE;
fbDut.uiRequestLimit := 3;
fbDut.xHandoverAllowed := TRUE;
fbDut.xRequireComm := TRUE;
afbPump[3].xAvailable := FALSE;                     // Н3 недоступен: готов к пуску только Н2, без связи

stCfg.tMaxContRun := T#10M;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 10, xPlant := TRUE);

AssertEquals_UINT(Expected := 1, Actual := fbDut.uiLead, Message := 'lead 1 with comm running');
afbPump[1].udiCurrentRunSeconds := 600;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 150, xPlant := TRUE);

AssertFalse(Condition := fbDut.axRun[2] OR fbDut.xHandover, Message := 'no handover to pump without comm');
AssertTrue(Condition := fbDut.axRun[1], Message := 'lead 1 keeps running');
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiLead, Message := 'lead stays 1');
// Н3 со связью снова доступен — передача роли после STN_HANDOVER_RETRY
afbPump[3].xAvailable := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#1S, uiSteps := 600, xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[3] AND NOT fbDut.axRun[2], Message := 'retry: replacement with comm');

coUnit.TEST_FINISHED();
