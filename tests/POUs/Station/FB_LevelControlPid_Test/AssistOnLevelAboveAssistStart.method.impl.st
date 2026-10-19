coUnit.TEST('LevelPid_AssistOnLevelAboveAssistStart_A7_PMI05');

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
fbDut(xEnable := TRUE, rLevel_m := 2.4, xLevelValid := TRUE, rPidOut_pct := 50.0, xInit := TRUE,
      uiInitPumps := 1, itfTime := fbTime, stCfg := stCfg);

Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 2.4, rPidOut_pct := 50.0, uiSteps := 49);
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequired, Message := 'one pump at t0 + 4.9 s');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 2.4, rPidOut_pct := 50.0, uiSteps := 1);
AssertEquals_UINT(Expected := 2, Actual := fbDut.uiRequired, Message := 'assist by level at t0 + 5 s');

coUnit.TEST_FINISHED();
