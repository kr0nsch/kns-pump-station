coUnit.TEST('Ats_TripEventNamesReplacementNotTrippedPump_A9_A16_PMI15_PMI16');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.itfEvents := fbSink;
fbDut.xEnable := TRUE;
fbDut.uiAvailable := 3;

fbDut.axRun[1] := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
fbTime.Advance(tStep := T#20MS);

// цикл отказа: блокировка станции, запрос ещё у Н1
fbDut.axTrip[1] := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.axRemoved[1], Message := 'trip is ATS');
AssertFalse(Condition := fbSink.Has(eFind := E_StationEvent.AtsPumpIn), Message := 'tripped pump is no replacement');
// следующий цикл: устройство недоступно, запрос — у Н2
fbTime.Advance(tStep := T#20MS);
afbPump[1].xAvailable := FALSE;
fbDut.axRun[1] := FALSE;
fbDut.axRun[2] := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertEquals_REAL(Expected := 2.0, Actual := fbSink.ValueOf(eFind := E_StationEvent.AtsPumpIn), Delta := 0.0,
                  Message := 'event 101006 names pump 2');
AssertEquals_UINT(Expected := 1, Actual := fbSink.CountOf(eFind := E_StationEvent.AtsPumpIn), Message := 'one event');

coUnit.TEST_FINISHED();
