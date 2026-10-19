coUnit.TEST('StationMode_AutoToManualRequestsManual_A3_PMI30');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.itfEvents := fbSink;

stRetain.eMode := E_StationMode.Auto;
afbPump[1].eMode := PL.E_DeviceMode.Auto;
afbPump[2].eMode := PL.E_DeviceMode.Local;
afbPump[3].eMode := PL.E_DeviceMode.OutOfService;
fbDut(stRetain := stRetain);
fbDut(xSetManual := TRUE, stRetain := stRetain);
AssertTrue(Condition := fbDut.eMode = E_StationMode.Manual AND fbDut.xEnteredManual, Message := 'Manual entered');
AssertTrue(Condition := afbPump[1].eLastModeRequest = PL.E_DeviceMode.Manual AND afbPump[1].uiRequestModeCalls = 1,
           Message := 'Auto pump: Manual requested');
AssertTrue(Condition := afbPump[2].eLastModeRequest = PL.E_DeviceMode.Manual AND afbPump[2].uiRequestModeCalls = 1,
           Message := 'Local pump: Manual requested');
AssertEquals_UINT(Expected := 0, Actual := afbPump[3].uiRequestModeCalls, Message := 'OutOfService pump untouched');
AssertTrue(Condition := fbSink.Has(eFind := E_StationEvent.StationManual), Message := 'event 101002');

coUnit.TEST_FINISHED();
