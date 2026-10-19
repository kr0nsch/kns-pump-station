coUnit.TEST('Ats_ModeChangeIsNotAts_A9_PMI31');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.itfEvents := fbSink;
fbDut.xEnable := TRUE;
fbDut.uiAvailable := 3;

fbDut.axRun[1] := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
fbTime.Advance(tStep := T#100MS);

afbPump[1].eMode := PL.E_DeviceMode.Local;
fbDut.axRun[1] := FALSE;
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xAtsActive, Message := 'mode change is not ATS');
AssertEquals_UDINT(Expected := 0, Actual := fbDut.udiAtsCount, Message := 'no ATS counted');

coUnit.TEST_FINISHED();
