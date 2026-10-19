coUnit.TEST('LevelPid_CommAbsentDuringPowerRestoreNoRecoverDelay_A7_A12_A13');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.axCommOk[1] := TRUE;
fbDut.axCommOk[2] := TRUE;
fbDut.axCommOk[3] := TRUE;
fbDut.ePidMode := PL.E_DeviceMode.Auto;
fbDut(xEnable := FALSE, rLevel_m := 1.2, xLevelValid := TRUE, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xPidReady, Message := 'stopped pumps with comm: ready');

// нет напряжения: насосы недоступны, ПЧ без питания — связи нет
fbDut.xPowerRestore := TRUE;
FOR uiIdx := 1 TO 3 DO
    afbPump[uiIdx].xAvailable := FALSE;
    fbDut.axCommOk[uiIdx] := FALSE;
END_FOR
FOR uiStep := 1 TO 100 DO
    fbTime.Advance(tStep := T#100MS);
    fbDut(xEnable := FALSE, itfTime := fbTime, stCfg := stCfg);
END_FOR
AssertFalse(Condition := fbDut.xPidReady, Message := 'power lost: not ready');
// напряжение восстановлено: насосы доступны, ПЧ 2 с загружаются
FOR uiIdx := 1 TO 3 DO
    afbPump[uiIdx].xAvailable := TRUE;
END_FOR
FOR uiStep := 1 TO 20 DO
    fbTime.Advance(tStep := T#100MS);
    fbDut(xEnable := FALSE, itfTime := fbTime, stCfg := stCfg);
END_FOR
AssertFalse(Condition := fbDut.xPidReady, Message := 'drives booting: not ready');
fbDut.axCommOk[1] := TRUE;
fbTime.Advance(tStep := T#100MS);
fbDut(xEnable := FALSE, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xPidReady, Message := 'drive booted: ready at once, no recover delay');

// после восстановления питания: связь пропала у всех — снова через STN_PID_RECOVER
fbDut.xPowerRestore := FALSE;
fbDut.axCommOk[1] := FALSE;
fbTime.Advance(tStep := T#100MS);
fbDut(xEnable := FALSE, itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xPidReady, Message := 'comm lost outside power restore: not ready');
fbDut.axCommOk[1] := TRUE;
FOR uiStep := 1 TO 300 DO
    fbTime.Advance(tStep := T#100MS);
    fbDut(xEnable := FALSE, itfTime := fbTime, stCfg := stCfg);
END_FOR
AssertFalse(Condition := fbDut.xPidReady, Message := 'not ready 29.9 s after comm recovery');
fbTime.Advance(tStep := T#100MS);
fbDut(xEnable := FALSE, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xPidReady, Message := 'ready 30 s after comm recovery');

coUnit.TEST_FINISHED();
