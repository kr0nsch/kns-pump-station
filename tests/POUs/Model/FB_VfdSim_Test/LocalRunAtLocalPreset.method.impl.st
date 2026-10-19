coUnit.TEST('VfdSim_LocalRunAtLocalPreset');

fbDut(xLocal := TRUE, xLocalRun := TRUE, uiFref := 0, itfTime := fbTime);
FOR uiI := 1 TO 10 * UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertTrue(Condition := fbDut.xOutputActive AND fbDut.xRelayRun, Message := 'local run starts the drive');
AssertEquals_REAL(Expected := R_LOCAL_HZ, Actual := fbDut.rFreq_Hz, Delta := R_EPS_HZ,
                  Message := 'local preset reached in tAccel');
fbDut.uiFref := UI_FREF_25HZ;
FOR uiI := 1 TO UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertEquals_REAL(Expected := R_LOCAL_HZ, Actual := fbDut.rFreq_Hz, Delta := R_EPS_HZ,
                  Message := 'master FREF ignored in local');
fbDut.xLocal := FALSE;
fbDut.xLocalRun := FALSE;
fbDut.xRunCmd := TRUE;
FOR uiI := 1 TO 5 * UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertEquals_REAL(Expected := 25.0, Actual := fbDut.rFreq_Hz, Delta := R_EPS_HZ, Message := 'remote: back to FREF');

coUnit.TEST_FINISHED();
