coUnit.TEST('Rotation_StopKeepsCommPumpInPid_A5_A12_PMI05_PMI28');

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
afbPump[3].xAvailable := FALSE;
afbPump[1].udiRunSeconds := 900;                    // насос со связью — с большей наработкой
afbPump[2].udiRunSeconds := 100;

Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 2,
      tStep := T#100MS, uiSteps := 60, xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[1] AND fbDut.axRun[2], Message := 'two pumps running');
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiLead, Message := 'PID: lead with comm');
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[1] AND NOT fbDut.axRun[2], Message := 'pump without comm stopped first');
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiLead, Message := 'lead with comm kept');
// без требования связи (ступенчатое) — по моточасам: останавливается насос с большей наработкой
fbDut.xRequireComm := FALSE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 2,
      tStep := T#100MS, uiSteps := 60, xPlant := TRUE);
Cycle(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, stRetain := stRetain, afbPump := afbPump, uiRequired := 1,
      tStep := T#100MS, uiSteps := 1, xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[2] AND NOT fbDut.axRun[1], Message := 'stepped: more hours pump stopped');

coUnit.TEST_FINISHED();
