coUnit.TEST('DeviceAudit_AuditLogsModeChange');

fbLog.itfTime := fbTime;
fbDi1(stCmd := stCmd1, stCfg := stCfg, itfTime := fbTime);
fbDi2(stCmd := stCmd2, stCfg := stCfg, itfTime := fbTime);
fbDut.aitfDevice[1] := fbDi1;
fbDut.aitfDevice[2] := fbDi2;
fbDut.auiDevNo[1] := 101;
fbDut.auiDevNo[2] := 102;
fbDut(itfEvents := fbLog);
fbDut(itfEvents := fbLog);
AssertEquals_UINT(Expected := 0, Actual := fbLog.uiCount, Message := 'no change, no event');
AssertTrue(Condition := fbDi2.RequestMode(eNewMode := PL.E_DeviceMode.Manual), Message := 'mode request accepted');
fbDi2(stCmd := stCmd2, stCfg := stCfg, itfTime := fbTime);
AssertTrue(Condition := fbDi2.Mode = PL.E_DeviceMode.Manual, Message := 'device in Manual');
fbDut(itfEvents := fbLog);
AssertEquals_UINT(Expected := 1, Actual := fbLog.uiCount, Message := 'one event');
fbLog.GetRecord(uiAge := 0, stRecord => stRec);
AssertEquals_UDINT(Expected := 101018, Actual := stRec.udiId, Message := 'event 101018');
AssertEquals_REAL(Expected := 1022.0, Actual := stRec.rValue, Delta := R_EPS, Message := 'value 102 * 10 + 2');
fbDut(itfEvents := fbLog);
AssertEquals_UINT(Expected := 1, Actual := fbLog.uiCount, Message := 'no repeat');

coUnit.TEST_FINISHED();
