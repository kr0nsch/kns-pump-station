coUnit.TEST('Ventilation_OverrunAfterConditionsClear_A17_PMI38');

fbDut(xDoorOpen := TRUE, itfTime := fbTime, stCfg := stCfg);
fbTime.Advance(tStep := T#1S);
fbDut(xDoorOpen := FALSE, itfTime := fbTime, stCfg := stCfg);
FOR uiStep := 1 TO 599 DO
    fbTime.Advance(tStep := T#1S);
    fbDut(itfTime := fbTime, stCfg := stCfg);
END_FOR
AssertTrue(Condition := fbDut.xRun, Message := 'overrun at 9 min 59 s');
fbTime.Advance(tStep := T#1S);
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xRun, Message := 'stop at 10 min');

coUnit.TEST_FINISHED();
