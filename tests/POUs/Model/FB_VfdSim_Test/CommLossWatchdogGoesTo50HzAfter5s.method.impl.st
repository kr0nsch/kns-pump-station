coUnit.TEST('VfdSim_CommLossWatchdogGoesTo50HzAfter5s');

fbDut(xRunCmd := TRUE, uiFref := UI_FREF_30HZ, itfTime := fbTime);
fbStopped(xRunCmd := FALSE, uiFref := 0, itfTime := fbTime);
FOR uiI := 1 TO 6 * UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
fbDut.xCommLoss := TRUE;
fbStopped.xCommLoss := TRUE;
fbTime.Advance(tStep := T_STEP);
fbDut(itfTime := fbTime);
fbStopped(itfTime := fbTime);
FOR uiI := 1 TO 5 * UI_1S - 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
    fbStopped(itfTime := fbTime);
END_FOR
AssertFalse(Condition := fbDut.xWatchdog, Message := 'no watchdog at 4.9 s');
AssertEquals_REAL(Expected := 30.0, Actual := fbDut.rRef_Hz, Delta := R_EPS_HZ, Message := 'last reference 30 Hz');
fbTime.Advance(tStep := T_STEP);
fbDut(itfTime := fbTime);
fbStopped(itfTime := fbTime);
AssertTrue(Condition := fbDut.xWatchdog AND fbStopped.xWatchdog, Message := 'watchdog at 5.0 s');
AssertEquals_REAL(Expected := GVL_Const.SIM_VFD_WATCHDOG_FREQ_HZ, Actual := fbDut.rRef_Hz, Delta := 0.0,
                  Message := 'preset 50 Hz');
FOR uiI := 1 TO 10 * UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
    fbStopped(xRunCmd := TRUE, itfTime := fbTime);
END_FOR
AssertEquals_REAL(Expected := 50.0, Actual := fbDut.rFreq_Hz, Delta := R_EPS_HZ, Message := 'running pump at 50 Hz');
AssertEquals_REAL(Expected := 50.0, Actual := fbStopped.rFreq_Hz, Delta := R_EPS_HZ,
                  Message := 'pump started by wire runs at 50 Hz');

coUnit.TEST_FINISHED();
