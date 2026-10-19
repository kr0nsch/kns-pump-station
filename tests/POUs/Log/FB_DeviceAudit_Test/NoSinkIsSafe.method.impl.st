coUnit.TEST('DeviceAudit_NoSinkIsSafe');

fbDi(stCmd := stCmd, stCfg := stCfg, itfTime := fbTime);
fbDut.aitfDevice[1] := fbDi;
fbDut.auiDevNo[1] := 103;
fbDut();
fbDi.RequestMode(eNewMode := PL.E_DeviceMode.OutOfService);
fbDi(stCmd := stCmd, stCfg := stCfg, itfTime := fbTime);
fbDut();
AssertEquals_UDINT(Expected := 1, Actual := fbDut.udiChanges, Message := 'change counted without sink');

coUnit.TEST_FINISHED();
