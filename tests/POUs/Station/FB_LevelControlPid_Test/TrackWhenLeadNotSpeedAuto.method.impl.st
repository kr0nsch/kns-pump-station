coUnit.TEST('LevelPid_TrackWhenLeadNotSpeedAuto_A7_PMI04');

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

afbPump[1].xSpeedAuto := FALSE;
afbPump[1].rSpeedRef := 72.0;
fbDut(xEnable := TRUE, rLevel_m := 1.5, xLevelValid := TRUE, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xTrack AND NOT fbDut.xPidControls, Message := 'lead not SpeedAuto: tracking');
AssertEquals_REAL(Expected := 72.0, Actual := fbDut.rTrack_pct, Delta := 0.0, Message := 'tracks lead SpeedRef');
afbPump[1].xSpeedAuto := TRUE;
fbDut(xEnable := TRUE, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xPidControls AND NOT fbDut.xTrack, Message := 'lead SpeedAuto: PID controls');
fbDut(xEnable := FALSE, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xTrack, Message := 'not selected: tracking');
fbDut.uiLead := 0;
fbDut(xEnable := TRUE, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xTrack, Message := 'no lead: tracking');
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.rTrack_pct, Delta := 0.0, Message := 'no lead: track 0');

coUnit.TEST_FINISHED();
