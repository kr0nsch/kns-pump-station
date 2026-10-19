coUnit.TEST('Annunciator_TimeBackwardsRestartsBlink_A14');

fbDut.auiUnack[2] := 1;
fbDut(itfTime := fbTime);
FOR uiStep := 1 TO 5 DO
    fbTime.Advance(tStep := T#100MS);
    fbDut(itfTime := fbTime);
END_FOR
AssertFalse(Condition := fbDut.xLamp, Message := 'off at 0.5 s');
fbTime.SetNow(ltValue := LTIME#59M);
fbDut(itfTime := fbTime);
AssertTrue(Condition := fbDut.xLamp, Message := 'blink restarted on time jump: on');
FOR uiStep := 1 TO 5 DO
    fbTime.Advance(tStep := T#100MS);
    fbDut(itfTime := fbTime);
END_FOR
AssertFalse(Condition := fbDut.xLamp, Message := 'off 0.5 s after restart');

coUnit.TEST_FINISHED();
