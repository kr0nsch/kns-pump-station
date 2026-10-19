coUnit.TEST('LevelPid_InitFromRunningPumps_A7_PMI07');

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
fbDut(xEnable := TRUE, rLevel_m := 1.5, xLevelValid := TRUE, rPidOut_pct := 70.0, xInit := TRUE,
      uiInitPumps := 3, itfTime := fbTime, stCfg := stCfg);

AssertEquals_UINT(Expected := 2, Actual := fbDut.uiRequired, Message := 'three running: limited to two');
stCfg1.uiDutyMax := 1;
fbDut2(xEnable := TRUE, rLevel_m := 1.5, xLevelValid := TRUE, xInit := TRUE, uiInitPumps := 2, itfTime := fbTime,
       stCfg := stCfg1);
AssertEquals_UINT(Expected := 1, Actual := fbDut2.uiRequired, Message := 'uiDutyMax = 1: one pump');

coUnit.TEST_FINISHED();
