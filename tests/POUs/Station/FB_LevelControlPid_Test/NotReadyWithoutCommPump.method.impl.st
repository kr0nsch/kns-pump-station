coUnit.TEST('LevelPid_NotReadyWithoutCommPump_A7_PMI29');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.axCommOk[1] := TRUE;
fbDut.axCommOk[2] := TRUE;
fbDut.axCommOk[3] := TRUE;
fbDut.ePidMode := PL.E_DeviceMode.Auto;

fbDut.axCommOk[1] := FALSE;
fbDut.axCommOk[2] := FALSE;
fbDut.axCommOk[3] := FALSE;
fbDut(xEnable := FALSE, rLevel_m := 1.5, xLevelValid := TRUE, itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xPidReady, Message := 'stopped pumps without comm: not ready');
afbPump[2].xRunning := TRUE;
fbDut.axCommOk[3] := TRUE;
fbDut(xEnable := FALSE, itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xPidReady,
            Message := 'running pump without comm, comm only on a stopped one: not ready');

coUnit.TEST_FINISHED();
