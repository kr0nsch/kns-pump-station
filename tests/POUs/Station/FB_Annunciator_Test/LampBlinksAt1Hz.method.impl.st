coUnit.TEST('Annunciator_LampBlinksAt1Hz_A14_PMI36');

fbDut.auiUnack[2] := 1;
fbDut(itfTime := fbTime);
AssertTrue(Condition := fbDut.xLamp, Message := 'on at blink start');
FOR uiStep := 1 TO 4 DO
    fbTime.Advance(tStep := T#100MS);
    fbDut(itfTime := fbTime);
END_FOR
AssertTrue(Condition := fbDut.xLamp, Message := 'on at 0.4 s');
fbTime.Advance(tStep := T#100MS);
fbDut(itfTime := fbTime);
AssertFalse(Condition := fbDut.xLamp, Message := 'off at 0.5 s');
FOR uiStep := 1 TO 4 DO
    fbTime.Advance(tStep := T#100MS);
    fbDut(itfTime := fbTime);
END_FOR
AssertFalse(Condition := fbDut.xLamp, Message := 'off at 0.9 s');
fbTime.Advance(tStep := T#100MS);
fbDut(itfTime := fbTime);
AssertTrue(Condition := fbDut.xLamp, Message := 'on again at 1.0 s');
fbDut2.auiUnack[1] := 1;
fbDut2(itfTime := fbTime);
AssertFalse(Condition := fbDut2.xLamp OR fbDut2.xHorn, Message := 'Low only: no lamp, no horn');

coUnit.TEST_FINISHED();
