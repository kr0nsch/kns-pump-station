coUnit.TEST('VfdSim_ResetDriveClearsFault');

fbDut(xRunCmd := TRUE, uiFref := UI_FREF_50HZ, itfTime := fbTime);
FOR uiI := 1 TO 10 * UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
fbDut.xFaultInj := TRUE;
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
fbDut.ResetDrive();
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertTrue(Condition := fbDut.xFaulted, Message := 'cause active: fault stays');
fbDut.xFaultInj := FALSE;
fbDut.ResetDrive();
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertFalse(Condition := fbDut.xFaulted, Message := 'ResetDrive clears fault');
AssertTrue(Condition := fbDut.xReady, Message := 'ready');

coUnit.TEST_FINISHED();
