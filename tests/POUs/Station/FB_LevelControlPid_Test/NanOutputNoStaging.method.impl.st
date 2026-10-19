coUnit.TEST('LevelPid_NanOutputNoStaging_A7');

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

uBits.dwValue := 16#7FC00000;
rNan := uBits.rValue;
fbDut(xEnable := TRUE, rLevel_m := 2.0, xLevelValid := TRUE, rPidOut_pct := rNan, xInit := TRUE,
      uiInitPumps := 1, itfTime := fbTime, stCfg := stCfg);

Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, rLevel_m := 2.0, rPidOut_pct := rNan, uiSteps := 600);
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiRequired, Message := 'NaN output: no assist');
fbDut2.aitfPump[1] := afbPump[1];
fbDut2.axCommOk[1] := TRUE;
fbDut2.uiLead := 1;
fbDut2.ePidMode := PL.E_DeviceMode.Auto;
fbDut2(xEnable := TRUE, rLevel_m := 2.0, xLevelValid := TRUE, rPidOut_pct := rNan, xInit := TRUE, uiInitPumps := 2,
       itfTime := fbTime, stCfg := stCfg);
Run(fbDut := fbDut2, fbTime := fbTime, stCfg := stCfg, rLevel_m := 2.0, rPidOut_pct := rNan, uiSteps := 700);
AssertEquals_UINT(Expected := 2, Actual := fbDut2.uiRequired, Message := 'NaN output: assist kept');

coUnit.TEST_FINISHED();
