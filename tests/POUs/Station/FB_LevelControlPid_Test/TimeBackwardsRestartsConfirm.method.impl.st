coUnit.TEST('LevelPid_TimeBackwardsRestartsConfirm_A7');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.axCommOk[1] := TRUE;
fbDut.axCommOk[2] := TRUE;
fbDut.axCommOk[3] := TRUE;
fbDut.ePidMode := PL.E_DeviceMode.Auto;
fbDut(xEnable := TRUE, rLevel_m := 1.7, xLevelValid := TRUE, rPidOut_pct := 0.0, xInit := TRUE,
      uiInitPumps := 0, itfTime := fbTime, stCfg := stCfg);

Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.7, rPidOut_pct := 0.0, uiSteps := 30);
fbTime.SetNow(ltValue := LTIME#59M);
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.7, rPidOut_pct := 0.0, uiSteps := 50);
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiRequired, Message := 'confirmation restarted after time jump');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.7, rPidOut_pct := 0.0, uiSteps := 1);
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequired, Message := 'start after full confirmation');

coUnit.TEST_FINISHED();
