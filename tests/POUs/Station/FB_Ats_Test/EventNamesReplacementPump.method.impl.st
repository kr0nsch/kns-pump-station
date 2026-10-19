coUnit.TEST('Ats_EventNamesReplacementPump_A9_A16_PMI12');

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
AssertFalse(Condition := fbSink.Has(eFind := E_StationEvent.AtsPumpIn), Message := 'no replacement yet');
fbTime.Advance(tStep := T#1S);
fbDut.axRun[3] := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertEquals_REAL(Expected := 3.0, Actual := fbSink.ValueOf(eFind := E_StationEvent.AtsPumpIn), Delta := 0.0,
                  Message := 'event 101006 names pump 3');
fbSink.Clear();
fbDut2.aitfPump[1] := afbPump[2];
fbDut2.itfEvents := fbSink;
fbDut2.xEnable := TRUE;
fbDut2.axRun[1] := TRUE;
fbDut2(itfTime := fbTime, stCfg := stCfg);
afbPump[2].xFault := TRUE;
fbDut2.axRun[1] := FALSE;
fbDut2(itfTime := fbTime, stCfg := stCfg);
FOR uiStep := 1 TO 101 DO
    fbTime.Advance(tStep := T#100MS);
    fbDut2(itfTime := fbTime, stCfg := stCfg);
END_FOR
fbDut2.axRun[2] := TRUE;
fbDut2(itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbSink.Has(eFind := E_StationEvent.AtsPumpIn),
            Message := 'request after the window: no event');

coUnit.TEST_FINISHED();
