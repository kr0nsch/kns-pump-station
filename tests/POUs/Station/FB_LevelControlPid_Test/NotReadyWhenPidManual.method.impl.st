coUnit.TEST('LevelPid_NotReadyWhenPidManual_A7');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.axCommOk[1] := TRUE;
fbDut.axCommOk[2] := TRUE;
fbDut.axCommOk[3] := TRUE;
fbDut.ePidMode := PL.E_DeviceMode.Auto;

afbPump[1].xRunning := TRUE;
afbPump[1].xSpeedAuto := TRUE;
afbPump[1].rSpeedRef := 60.0;
fbDut.uiLead := 1;

fbDut.ePidMode := PL.E_DeviceMode.Manual;
fbDut(xEnable := TRUE, rLevel_m := 1.5, xLevelValid := TRUE, itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xPidReady, Message := 'PID Manual: not ready');
fbDut.ePidMode := PL.E_DeviceMode.Auto;
fbDut(xEnable := TRUE, rLevel_m := 1.5, xLevelValid := FALSE, itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xPidReady, Message := 'level invalid: not ready');
fbDut(xEnable := TRUE, rLevel_m := 1.5, xLevelValid := TRUE, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xPidReady, Message := 'Auto and valid level: ready');

coUnit.TEST_FINISHED();
