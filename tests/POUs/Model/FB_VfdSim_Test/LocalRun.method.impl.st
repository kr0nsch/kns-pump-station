coUnit.TEST('VfdSim_LocalRun');

fbDut(xRunCmd := TRUE, xLocal := TRUE, uiFref := UI_FREF_50HZ, itfTime := fbTime);
FOR uiI := 1 TO UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertFalse(Condition := fbDut.xOutputActive, Message := 'PLC wire ignored in local');
AssertEquals_WORD(Expected := GVL_Const.VFD_STW_READY, Actual := fbDut.wStw, Message := 'STW without remote bit');
fbDut.xLocalRun := TRUE;
FOR uiI := 1 TO UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertTrue(Condition := fbDut.xOutputActive AND fbDut.xRelayRun, Message := 'local run starts the drive');
AssertEquals_REAL(Expected := 5.0, Actual := fbDut.rFreq_Hz, Delta := R_EPS_HZ, Message := 'ramp in local');

coUnit.TEST_FINISHED();
