coUnit.TEST('LevelPid_StartsLeadAtStartLevel_A7_PMI04');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.axCommOk[1] := TRUE;
fbDut.axCommOk[2] := TRUE;
fbDut.axCommOk[3] := TRUE;
fbDut.ePidMode := PL.E_DeviceMode.Auto;
fbDut(xEnable := TRUE, rLevel_m := 1.6, xLevelValid := TRUE, rPidOut_pct := 0.0, xInit := TRUE,
      uiInitPumps := 0, itfTime := fbTime, stCfg := stCfg);

Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.6, rPidOut_pct := 0.0, uiSteps := 49);
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiRequired, Message := 'no pump at t0 + 4.9 s');
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 1.6, rPidOut_pct := 0.0, uiSteps := 1);
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequired, Message := 'lead at t0 + 5 s');
AssertTrue(Condition := fbDut.xPidReady, Message := 'ready: stopped pumps available with comm');

coUnit.TEST_FINISHED();
