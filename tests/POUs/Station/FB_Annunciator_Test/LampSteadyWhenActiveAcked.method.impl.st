coUnit.TEST('Annunciator_LampSteadyWhenActiveAcked_A14_PMI36');

fbDut.auiActive[2] := 1;
fbDut(itfTime := fbTime);
FOR uiStep := 1 TO 20 DO
    fbTime.Advance(tStep := T#100MS);
    fbDut(itfTime := fbTime);
    xEverOff := xEverOff OR NOT fbDut.xLamp;
END_FOR
AssertFalse(Condition := xEverOff, Message := 'steady on while active acked');
fbDut.auiActive[2] := 0;
fbDut(itfTime := fbTime);
AssertFalse(Condition := fbDut.xLamp, Message := 'off without alarms');

coUnit.TEST_FINISHED();
