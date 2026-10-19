coUnit.TEST('Ventilation_TimeBackwardsRestartsOverrun_A17');

fbDut(xDoorOpen := TRUE, itfTime := fbTime, stCfg := stCfg);
fbTime.Advance(tStep := T#1S);
fbDut(xDoorOpen := FALSE, itfTime := fbTime, stCfg := stCfg);
FOR uiStep := 1 TO 100 DO
    fbTime.Advance(tStep := T#1S);
    fbDut(itfTime := fbTime, stCfg := stCfg);
END_FOR
fbTime.SetNow(ltValue := LTIME#59M);
FOR uiStep := 1 TO 600 DO
    fbTime.Advance(tStep := T#1S);
    fbDut(itfTime := fbTime, stCfg := stCfg);
END_FOR
AssertTrue(Condition := fbDut.xRun, Message := 'overrun restarted after time jump');
fbTime.Advance(tStep := T#1S);
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xRun, Message := 'stop after full overrun');

coUnit.TEST_FINISHED();
