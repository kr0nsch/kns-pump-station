coUnit.TEST('LevelPid_TrackWhenLeadCommLost_A7_A12_PMI28');

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

fbDut.axCommOk[1] := FALSE;
fbDut(xEnable := TRUE, rLevel_m := 1.5, xLevelValid := TRUE, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xTrack AND NOT fbDut.xPidControls, Message := 'lead without comm: tracking');

coUnit.TEST_FINISHED();
