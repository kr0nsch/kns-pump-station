coUnit.TEST('VfdSim_CommRestoredFollowsFref');

fbDut(xRunCmd := TRUE, uiFref := UI_FREF_50HZ, itfTime := fbTime);
FOR uiI := 1 TO 10 * UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
fbDut.xCommLoss := TRUE;
FOR uiI := 1 TO 6 * UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertTrue(Condition := fbDut.xWatchdog, Message := 'watchdog active');
fbDut.xCommLoss := FALSE;
fbDut.uiFref := UI_FREF_30HZ;
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertTrue(Condition := fbDut.xCommOk AND NOT fbDut.xWatchdog, Message := 'comm restored, watchdog off');
AssertEquals_REAL(Expected := 30.0, Actual := fbDut.rRef_Hz, Delta := R_EPS_HZ, Message := 'follows FREF again');
FOR uiI := 1 TO 4 * UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertEquals_REAL(Expected := 30.0, Actual := fbDut.rFreq_Hz, Delta := R_EPS_HZ, Message := 'ramped to 30 Hz');
AssertEquals_UINT(Expected := 3000, Actual := fbDut.uiFact, Message := 'FACT updated');

coUnit.TEST_FINISHED();
