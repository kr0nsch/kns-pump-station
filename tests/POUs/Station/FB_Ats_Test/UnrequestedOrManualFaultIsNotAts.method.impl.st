coUnit.TEST('Ats_UnrequestedOrManualFaultIsNotAts_A9_PMI14');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.itfEvents := fbSink;
fbDut.xEnable := TRUE;
fbDut.uiAvailable := 3;

fbDut.axRun[1] := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
fbTime.Advance(tStep := T#100MS);

afbPump[2].xFault := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xAtsActive, Message := 'unrequested pump fault: no ATS');
fbDut.xEnable := FALSE;
afbPump[1].xFault := TRUE;
fbDut.axRun[1] := FALSE;
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xAtsActive, Message := 'station Manual: no ATS');

coUnit.TEST_FINISHED();
