coUnit.TEST('LevelPid_AssistNotOffAboveAssistStartLevel_A7');

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
fbDut(xEnable := TRUE, rLevel_m := 2.5, xLevelValid := TRUE, rPidOut_pct := 50.0, xInit := TRUE,
      uiInitPumps := 2, itfTime := fbTime, stCfg := stCfg);

Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 2.5, rPidOut_pct := 50.0, uiSteps := 1200);
AssertEquals_UINT(Expected := 2, Actual := fbDut.uiRequired, Message := 'two pumps kept at 2.5 m');

coUnit.TEST_FINISHED();
