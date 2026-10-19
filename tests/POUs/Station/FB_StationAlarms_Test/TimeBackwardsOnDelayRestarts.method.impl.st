coUnit.TEST('StationAlarms_TimeBackwardsOnDelayRestarts_A15');

fbDut.axCond[E_StationAlarm.LACK] := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
fbTime.Advance(tStep := T#5S);
fbDut(itfTime := fbTime, stCfg := stCfg);
fbTime.SetNow(ltValue := LTIME#59M);
FOR uiStep := 1 TO 100 DO
    fbTime.Advance(tStep := T#100MS);
    fbDut(itfTime := fbTime, stCfg := stCfg);
END_FOR
AssertEquals_WORD(Expected := 0, Actual := fbDut.wAlmActive, Message := 'on-delay restarted after time jump');
fbTime.Advance(tStep := T#100MS);
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertEquals_WORD(Expected := 16#0004, Actual := fbDut.wAlmActive, Message := 'active after full on-delay');

coUnit.TEST_FINISHED();
