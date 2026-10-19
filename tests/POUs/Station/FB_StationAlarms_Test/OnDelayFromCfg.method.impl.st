coUnit.TEST('StationAlarms_OnDelayFromCfg_A15_PMI17');

fbDut.axCond[E_StationAlarm.LACK] := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
FOR uiStep := 1 TO 99 DO
    fbTime.Advance(tStep := T#100MS);
    fbDut(itfTime := fbTime, stCfg := stCfg);
END_FOR
AssertEquals_WORD(Expected := 0, Actual := fbDut.wAlmActive, Message := 'LACK not active at 9.9 s');
fbTime.Advance(tStep := T#100MS);
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertEquals_WORD(Expected := 16#0004, Actual := fbDut.wAlmActive, Message := 'LACK active at 10 s');

coUnit.TEST_FINISHED();
