coUnit.TEST('Ats_RequestedPumpFaultRaisesAts_A9_PMI12_PMI13');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.itfEvents := fbSink;
fbDut.xEnable := TRUE;
fbDut.uiAvailable := 3;

fbDut.axRun[1] := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
fbTime.Advance(tStep := T#100MS);

afbPump[1].xFault := TRUE;
fbDut.axRun[1] := FALSE;
fbDut.axRun[2] := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xAtsActive AND fbDut.axRemoved[1], Message := 'ATS active, pump 1 removed');
AssertEquals_UDINT(Expected := 1, Actual := fbDut.udiAtsCount, Message := 'one ATS counted');
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertEquals_UDINT(Expected := 1, Actual := fbDut.udiAtsCount, Message := 'counted once');

coUnit.TEST_FINISHED();
