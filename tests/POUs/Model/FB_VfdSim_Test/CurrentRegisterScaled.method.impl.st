coUnit.TEST('VfdSim_CurrentRegisterScaled');

fbDut(xRunCmd := TRUE, uiFref := UI_FREF_50HZ, itfTime := fbTime);
FOR uiI := 1 TO 10 * UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
fbDut.rMotorCurrent_A := 26.38;
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertEquals_UINT(Expected := 264, Actual := fbDut.uiCurrent, Message := '26.38 A -> 264');
uBits.dwValue := 16#7FC00000;
fbDut.rMotorCurrent_A := uBits.rValue;
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiCurrent, Message := 'NaN current -> 0');
fbDut.rMotorCurrent_A := 26.38;
fbDut.xRunCmd := FALSE;
FOR uiI := 1 TO 11 * UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiCurrent, Message := 'stopped drive -> 0');

coUnit.TEST_FINISHED();
