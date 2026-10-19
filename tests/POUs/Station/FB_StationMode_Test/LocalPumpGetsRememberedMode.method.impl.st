coUnit.TEST('StationMode_LocalPumpGetsRememberedMode_A3_PMI31');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.itfEvents := fbSink;

afbPump[1].eMode := PL.E_DeviceMode.Local;
afbPump[1].xFollowRequests := TRUE;
fbDut(stRetain := stRetain);
fbDut(xSetAuto := TRUE, stRetain := stRetain);
AssertTrue(Condition := afbPump[1].eMode = PL.E_DeviceMode.Local, Message := 'pump stays Local');
AssertTrue(Condition := afbPump[1].eRememberedMode = PL.E_DeviceMode.Auto, Message := 'remembered mode is Auto');

coUnit.TEST_FINISHED();
