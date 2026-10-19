coUnit.TEST('Ats_AtsClearsWhenPumpAvailableAgain_A9_PMI12');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.itfEvents := fbSink;
fbDut.xEnable := TRUE;
fbDut.uiAvailable := 3;

fbDut.axRun[1] := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
fbTime.Advance(tStep := T#100MS);

afbPump[1].xFault := TRUE;
fbDut.axRun[1] := FALSE;
fbDut(itfTime := fbTime, stCfg := stCfg);
afbPump[1].xFault := FALSE;
afbPump[1].eMode := PL.E_DeviceMode.Manual;
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xAtsActive, Message := 'reset but in Manual: still removed');
afbPump[1].eMode := PL.E_DeviceMode.Auto;
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xAtsActive OR fbDut.axRemoved[1], Message := 'available again: ATS cleared');

coUnit.TEST_FINISHED();
