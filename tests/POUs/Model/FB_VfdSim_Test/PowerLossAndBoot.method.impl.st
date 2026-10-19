coUnit.TEST('VfdSim_PowerLossAndBoot');

fbDut(xRunCmd := TRUE, uiFref := UI_FREF_50HZ, itfTime := fbTime);
FOR uiI := 1 TO 10 * UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
fbDut.xPowerOk := FALSE;
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.rFreq_Hz, Delta := 0.0, Message := 'no power: frequency 0');
AssertFalse(Condition := fbDut.xRelayRun OR fbDut.xCommOk OR fbDut.xReady, Message := 'no power: relays, comm off');
AssertEquals_WORD(Expected := 0, Actual := fbDut.wStw, Message := 'no power: STW 0');
fbDut.xPowerOk := TRUE;
FOR uiI := 1 TO 5 * UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertFalse(Condition := fbDut.xReady OR fbDut.xCommOk, Message := 'booting at 4.9 s');
AssertEquals_WORD(Expected := 0, Actual := fbDut.wStw, Message := 'booting: STW 0');
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertTrue(Condition := fbDut.xReady AND fbDut.xCommOk, Message := 'ready after boot');
AssertEquals_UINT(Expected := GVL_Const.SIM_VFD_FCODE_UNDERVOLT, Actual := fbDut.uiFcode,
                  Message := 'last fault: undervoltage');
AssertTrue(Condition := fbDut.xOutputActive, Message := 'held wired run restarts after boot');

coUnit.TEST_FINISHED();
