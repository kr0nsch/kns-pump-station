coUnit.TEST('VfdSim_RampToReference');

fbDut(xRunCmd := TRUE, uiFref := UI_FREF_50HZ, itfTime := fbTime);
FOR uiI := 1 TO 5 * UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertEquals_REAL(Expected := 25.0, Actual := fbDut.rFreq_Hz, Delta := R_EPS_HZ, Message := '25 Hz after 5 s');
AssertEquals_UINT(Expected := 2500, Actual := fbDut.uiFact, Message := 'FACT 2500');
AssertTrue(Condition := fbDut.xRelayRun, Message := 'run relay closed');
AssertEquals_WORD(Expected := GVL_Const.VFD_STW_READY OR GVL_Const.VFD_STW_RUNNING OR GVL_Const.VFD_STW_REMOTE,
                  Actual := fbDut.wStw, Message := 'STW ready + running + remote');
FOR uiI := 1 TO 5 * UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertEquals_REAL(Expected := 50.0, Actual := fbDut.rFreq_Hz, Delta := R_EPS_HZ, Message := '50 Hz after 10 s');
AssertEquals_UINT(Expected := 5000, Actual := fbDut.uiFact, Message := 'FACT 5000');
fbDut.xRunCmd := FALSE;
FOR uiI := 1 TO 10 * UI_1S - 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertEquals_REAL(Expected := 0.5, Actual := fbDut.rFreq_Hz, Delta := R_EPS_HZ, Message := 'decelerating: 0.5 Hz');
AssertTrue(Condition := fbDut.xRelayRun, Message := 'run relay closed while decelerating');
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.rFreq_Hz, Delta := 0.0, Message := 'stopped');
AssertFalse(Condition := fbDut.xRelayRun OR fbDut.xOutputActive, Message := 'run relay open after stop');

coUnit.TEST_FINISHED();
