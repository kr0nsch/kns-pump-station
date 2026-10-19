coUnit.TEST('LevelPid_HoldOutputWhenLeadDropsOut_A7_A9');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.axCommOk[1] := TRUE;
fbDut.axCommOk[2] := TRUE;
fbDut.axCommOk[3] := TRUE;
fbDut.ePidMode := PL.E_DeviceMode.Auto;

// ведущий 1 и подпорный 2 работают с общим заданием 97 %, ПИД управляет
afbPump[1].xRunning := TRUE;
afbPump[1].xSpeedAuto := TRUE;
afbPump[1].rSpeedRef := 97.0;
afbPump[2].xRunning := TRUE;
afbPump[2].xSpeedAuto := TRUE;
afbPump[2].rSpeedRef := 97.0;
fbDut.uiLead := 1;
fbDut(xEnable := TRUE, rLevel_m := 1.6, xLevelValid := TRUE, rPidOut_pct := 97.0, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xPidControls AND NOT fbDut.xTrack, Message := 'lead SpeedAuto: PID controls');

// авария ПЧ ведущего: устройство остановило насос, задание на ПЧ 0, насос недоступен; роль передаст
// FB_PumpRotation в этом же цикле, а ПИД видит ведущего прошлого цикла
afbPump[1].xFault := TRUE;
afbPump[1].xRunning := FALSE;
afbPump[1].xSpeedAuto := FALSE;
afbPump[1].rSpeedRef := 0.0;
fbDut(xEnable := TRUE, rPidOut_pct := 97.0, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xTrack AND NOT fbDut.xPidControls, Message := 'faulted lead: tracking');
AssertEquals_REAL(Expected := 97.0, Actual := fbDut.rTrack_pct, Delta := 0.0,
                  Message := 'faulted lead: PID output held, not the 0 of the failed drive');

// блокировка станции (недогрузка, перегрев): насос недоступен и остановлен, отказа устройства ещё нет
afbPump[1].xFault := FALSE;
afbPump[1].xAvailable := FALSE;
fbDut(xEnable := TRUE, rPidOut_pct := 96.0, itfTime := fbTime, stCfg := stCfg);
AssertEquals_REAL(Expected := 96.0, Actual := fbDut.rTrack_pct, Delta := 0.0,
                  Message := 'interlocked lead: PID output held');

// ПИД не выбран (ступенчатое управление) — слежение за заданием ведущего, как раньше
fbDut(xEnable := FALSE, rPidOut_pct := 96.0, itfTime := fbTime, stCfg := stCfg);
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.rTrack_pct, Delta := 0.0,
                  Message := 'PID not selected: tracks lead SpeedRef');

// ведущий доступен, но ещё не в SpeedAutoActive (пуск с минимальной частоты) — слежение за его заданием
afbPump[1].xAvailable := TRUE;
afbPump[1].rSpeedRef := 60.0;
fbDut(xEnable := TRUE, rPidOut_pct := 96.0, itfTime := fbTime, stCfg := stCfg);
AssertEquals_REAL(Expected := 60.0, Actual := fbDut.rTrack_pct, Delta := 0.0,
                  Message := 'starting lead: tracks its SpeedRef');

coUnit.TEST_FINISHED();
