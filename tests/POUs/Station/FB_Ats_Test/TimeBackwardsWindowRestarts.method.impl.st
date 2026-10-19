coUnit.TEST('Ats_TimeBackwardsWindowRestarts_A9');

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
fbDut(itfTime := fbTime, stCfg := stCfg);
fbTime.SetNow(ltValue := LTIME#59M);
FOR uiStep := 1 TO 95 DO
    fbTime.Advance(tStep := T#100MS);
    fbDut(itfTime := fbTime, stCfg := stCfg);
END_FOR
fbDut.axRun[2] := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertEquals_REAL(Expected := 2.0, Actual := fbSink.ValueOf(eFind := E_StationEvent.AtsPumpIn), Delta := 0.0,
                  Message := 'replacement inside restarted window');

coUnit.TEST_FINISHED();
