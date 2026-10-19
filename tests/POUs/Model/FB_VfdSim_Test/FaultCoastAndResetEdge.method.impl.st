coUnit.TEST('VfdSim_FaultCoastAndResetEdge');

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
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.rFreq_Hz, Delta := 0.0, Message := 'coast: frequency 0');
AssertTrue(Condition := fbDut.xRelayFault AND fbDut.xFaulted AND NOT fbDut.xReady, Message := 'fault latched');
AssertFalse(Condition := fbDut.xRelayRun, Message := 'run relay open');
AssertEquals_WORD(Expected := GVL_Const.VFD_STW_FAULT OR GVL_Const.VFD_STW_REMOTE, Actual := fbDut.wStw,
                  Message := 'STW fault + remote');
AssertEquals_UINT(Expected := GVL_Const.SIM_VFD_FCODE_EXT, Actual := fbDut.uiFcode, Message := 'fault code 11');
fbDut.wCtw := GVL_Const.VFD_CTW_RESET;
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertTrue(Condition := fbDut.xFaulted, Message := 'reset ignored while cause active');
fbDut.xFaultInj := FALSE;
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertTrue(Condition := fbDut.xFaulted, Message := 'no new reset edge: still faulted');
fbDut.wCtw := 0;
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
fbDut.wCtw := GVL_Const.VFD_CTW_RESET;
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertFalse(Condition := fbDut.xFaulted OR fbDut.xRelayFault, Message := 'reset edge clears fault');
AssertTrue(Condition := fbDut.xReady, Message := 'ready again');
AssertEquals_UINT(Expected := GVL_Const.SIM_VFD_FCODE_EXT, Actual := fbDut.uiFcode, Message := 'last fault code kept');
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertTrue(Condition := fbDut.xOutputActive AND fbDut.rFreq_Hz > 0.0, Message := 'wired run restarts the drive');

coUnit.TEST_FINISHED();
