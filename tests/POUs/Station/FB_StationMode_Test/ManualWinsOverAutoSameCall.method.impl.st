coUnit.TEST('StationMode_ManualWinsOverAutoSameCall_A3');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.itfEvents := fbSink;

stRetain.eMode := E_StationMode.Auto;
fbDut(stRetain := stRetain);
fbDut(xSetAuto := TRUE, xSetManual := TRUE, stRetain := stRetain);
AssertTrue(Condition := fbDut.eMode = E_StationMode.Manual, Message := 'Manual wins');
AssertEquals_UINT(Expected := 2, Actual := fbDut.uiCmdCount, Message := 'both pulses counted');
AssertTrue(Condition := fbDut.eCmdResult = PL.E_CmdResult.Accepted, Message := 'accepted');
AssertFalse(Condition := fbSink.Has(eFind := E_StationEvent.StationAuto), Message := 'no Auto event');
AssertTrue(Condition := fbSink.Has(eFind := E_StationEvent.StationManual), Message := 'Manual event');

coUnit.TEST_FINISHED();
