coUnit.TEST('StationMode_EnteredAutoPulsesOnFirstCallInAuto_A3_A13');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.itfEvents := fbSink;

stRetain.eMode := E_StationMode.Auto;
afbPump[1].eMode := PL.E_DeviceMode.Manual;
fbDut(stRetain := stRetain);
AssertTrue(Condition := fbDut.xEnteredAuto, Message := 'first call in Auto pulses entry');
AssertEquals_UINT(Expected := 0, Actual := afbPump[1].uiRequestModeCalls, Message := 'no mode requests at start');
AssertFalse(Condition := fbSink.Has(eFind := E_StationEvent.StationAuto), Message := 'no Auto event at start');
fbDut(stRetain := stRetain);
AssertFalse(Condition := fbDut.xEnteredAuto, Message := 'pulse lasts one call');

coUnit.TEST_FINISHED();
