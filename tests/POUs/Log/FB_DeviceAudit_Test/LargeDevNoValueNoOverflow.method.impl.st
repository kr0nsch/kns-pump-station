coUnit.TEST('DeviceAudit_LargeDevNoValueNoOverflow');

fbLog.itfTime := fbTime;
fbDi(stCmd := stCmd, stCfg := stCfg, itfTime := fbTime);
fbDut.aitfDevice[1] := fbDi;
fbDut.auiDevNo[1] := 9999;
fbDut(itfEvents := fbLog);
fbDi.RequestMode(eNewMode := PL.E_DeviceMode.Manual);
fbDi(stCmd := stCmd, stCfg := stCfg, itfTime := fbTime);
fbDut(itfEvents := fbLog);
AssertTrue(Condition := fbLog.GetRecord(uiAge := 0, stRecord => stRec), Message := 'event logged');
AssertEquals_REAL(Expected := 99992.0, Actual := stRec.rValue, Delta := R_EPS, Message := 'value 9999 * 10 + 2');

coUnit.TEST_FINISHED();
