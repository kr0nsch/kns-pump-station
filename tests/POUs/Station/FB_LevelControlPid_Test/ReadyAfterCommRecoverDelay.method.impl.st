coUnit.TEST('LevelPid_ReadyAfterCommRecoverDelay_A7_A12_PMI28');

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

fbDut(xEnable := TRUE, rLevel_m := 1.5, xLevelValid := TRUE, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xPidReady, Message := 'running pump with comm: ready');
fbDut.axCommOk[1] := FALSE;
fbDut.axCommOk[2] := FALSE;
fbDut.axCommOk[3] := FALSE;
fbTime.Advance(tStep := T#100MS);
fbDut(xEnable := TRUE, itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xPidReady, Message := 'comm lost: not ready at once');
fbDut.axCommOk[1] := TRUE;
FOR uiStep := 1 TO 300 DO
    fbTime.Advance(tStep := T#100MS);
    fbDut(xEnable := TRUE, itfTime := fbTime, stCfg := stCfg);
END_FOR
AssertFalse(Condition := fbDut.xPidReady, Message := 'not ready 29.9 s after comm recovery');
fbTime.Advance(tStep := T#100MS);
fbDut(xEnable := TRUE, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xPidReady, Message := 'ready 30 s after comm recovery');

coUnit.TEST_FINISHED();
