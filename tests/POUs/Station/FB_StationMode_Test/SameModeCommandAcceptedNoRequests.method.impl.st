coUnit.TEST('StationMode_SameModeCommandAcceptedNoRequests_A3');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.itfEvents := fbSink;

stRetain.eMode := E_StationMode.Auto;
afbPump[1].eMode := PL.E_DeviceMode.Manual;
fbDut(stRetain := stRetain);
fbDut(xSetAuto := TRUE, stRetain := stRetain);
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiCmdCount, Message := 'command counted');
AssertTrue(Condition := fbDut.eCmdResult = PL.E_CmdResult.Accepted, Message := 'accepted');
AssertEquals_UINT(Expected := 0, Actual := afbPump[1].uiRequestModeCalls, Message := 'no mode requests');
AssertFalse(Condition := fbDut.xEnteredAuto, Message := 'no entry pulse');
AssertEquals_UDINT(Expected := 0, Actual := fbSink.udiCount, Message := 'no events');

coUnit.TEST_FINISHED();
