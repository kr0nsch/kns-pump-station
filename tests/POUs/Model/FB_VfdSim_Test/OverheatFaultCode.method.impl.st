coUnit.TEST('VfdSim_OverheatFaultCode');

fbDut(xRunCmd := TRUE, uiFref := UI_FREF_50HZ, itfTime := fbTime);
FOR uiI := 1 TO 10 * UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
fbDut.xOverheat := TRUE;
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertTrue(Condition := fbDut.xFaulted AND fbDut.xRelayFault, Message := 'overheat trips the drive');
AssertEquals_UINT(Expected := GVL_Const.SIM_VFD_FCODE_OVERHEAT, Actual := fbDut.uiFcode, Message := 'fault code 12');
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.rFreq_Hz, Delta := 0.0, Message := 'coast');

coUnit.TEST_FINISHED();
