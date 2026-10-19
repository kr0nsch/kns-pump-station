coUnit.TEST('DeviceAudit_NoEventOnFirstCall');

fbLog.itfTime := fbTime;
fbDi(stCmd := stCmd, stCfg := stCfg, itfTime := fbTime);
fbDut.aitfDevice[1] := fbDi;
fbDut.auiDevNo[1] := 102;
fbDut(itfEvents := fbLog);
AssertEquals_UINT(Expected := 0, Actual := fbLog.uiCount, Message := 'no event on first call');
AssertEquals_UDINT(Expected := 0, Actual := fbDut.udiChanges, Message := 'no change counted');

coUnit.TEST_FINISHED();
