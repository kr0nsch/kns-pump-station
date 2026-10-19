coUnit.TEST('VfdSim_CommLossFreezesRegisters');

fbDut(xRunCmd := TRUE, uiFref := UI_FREF_25HZ, itfTime := fbTime);
FOR uiI := 1 TO 6 * UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertEquals_UINT(Expected := 2500, Actual := fbDut.uiFact, Message := 'FACT 2500 before loss');
fbDut.xCommLoss := TRUE;
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertFalse(Condition := fbDut.xCommOk, Message := 'no comm');
fbDut.uiFref := UI_FREF_50HZ;
FOR uiI := 1 TO 2 * UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertEquals_REAL(Expected := 25.0, Actual := fbDut.rFreq_Hz, Delta := R_EPS_HZ,
                  Message := 'new reference not received');
fbDut.xRunCmd := FALSE;
FOR uiI := 1 TO 2 * UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertEquals_REAL(Expected := 15.0, Actual := fbDut.rFreq_Hz, Delta := R_EPS_HZ, Message := 'wired stop works');
AssertEquals_UINT(Expected := 2500, Actual := fbDut.uiFact, Message := 'FACT frozen');
AssertEquals_WORD(Expected := GVL_Const.VFD_STW_READY OR GVL_Const.VFD_STW_RUNNING OR GVL_Const.VFD_STW_REMOTE,
                  Actual := fbDut.wStw, Message := 'STW frozen');

coUnit.TEST_FINISHED();
