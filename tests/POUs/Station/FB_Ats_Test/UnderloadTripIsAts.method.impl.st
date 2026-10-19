coUnit.TEST('Ats_UnderloadTripIsAts_A9_A10_PMI15');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.itfEvents := fbSink;
fbDut.xEnable := TRUE;
fbDut.uiAvailable := 3;

fbDut.axRun[1] := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
fbTime.Advance(tStep := T#100MS);

fbDut.axTrip[1] := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xAtsActive AND fbDut.axRemoved[1], Message := 'underload trip is ATS');
fbDut.axRun[1] := FALSE;
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.axRemoved[1], Message := 'removed while trip latched (pump still available)');
fbDut.axTrip[1] := FALSE;
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.axRemoved[1], Message := 'released after reset');

coUnit.TEST_FINISHED();
