coUnit.TEST('StationMode_ManualToAutoRequestsAutoExceptOos_A3_PMI30');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.itfEvents := fbSink;

afbPump[1].eMode := PL.E_DeviceMode.Manual;
afbPump[2].eMode := PL.E_DeviceMode.OutOfService;
afbPump[3].eMode := PL.E_DeviceMode.Local;
fbDut(stRetain := stRetain);
fbDut(xSetAuto := TRUE, stRetain := stRetain);
AssertTrue(Condition := fbDut.eMode = E_StationMode.Auto AND stRetain.eMode = E_StationMode.Auto,
           Message := 'station in Auto, retained');
AssertTrue(Condition := fbDut.xEnteredAuto, Message := 'Auto entry pulse');
AssertEquals_UINT(Expected := 1, Actual := afbPump[1].uiRequestModeCalls, Message := 'Manual pump requested');
AssertTrue(Condition := afbPump[1].eLastModeRequest = PL.E_DeviceMode.Auto, Message := 'Manual pump: Auto requested');
AssertEquals_UINT(Expected := 0, Actual := afbPump[2].uiRequestModeCalls, Message := 'OutOfService pump untouched');
AssertEquals_UINT(Expected := 1, Actual := afbPump[3].uiRequestModeCalls, Message := 'Local pump requested');
AssertTrue(Condition := fbSink.Has(eFind := E_StationEvent.StationAuto), Message := 'event 101001');
AssertTrue(Condition := fbDut.eCmdResult = PL.E_CmdResult.Accepted AND fbDut.uiCmdCount = 1,
           Message := 'one command accepted');

coUnit.TEST_FINISHED();
