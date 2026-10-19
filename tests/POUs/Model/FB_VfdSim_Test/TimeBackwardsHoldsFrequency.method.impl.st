coUnit.TEST('VfdSim_TimeBackwardsHoldsFrequency');

fbDut(xRunCmd := TRUE, uiFref := UI_FREF_50HZ, itfTime := fbTime);
FOR uiI := 1 TO 3 * UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertEquals_REAL(Expected := 15.0, Actual := fbDut.rFreq_Hz, Delta := R_EPS_HZ, Message := '15 Hz after 3 s');
fbTime.SetNow(ltValue := fbTime.Now() - LTIME#1S);
fbDut(itfTime := fbTime);
AssertEquals_REAL(Expected := 15.0, Actual := fbDut.rFreq_Hz, Delta := R_EPS_HZ,
                  Message := 'time back: frequency held');
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertEquals_REAL(Expected := 15.5, Actual := fbDut.rFreq_Hz, Delta := R_EPS_HZ, Message := 'ramp resumes');

coUnit.TEST_FINISHED();
