coUnit.TEST('StationMode_EmptyRetainStartsManual_A3');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.itfEvents := fbSink;

fbDut(stRetain := stRetain);
AssertTrue(Condition := fbDut.eMode = E_StationMode.Manual, Message := 'empty retain: Manual');
AssertTrue(Condition := fbDut.eMethod = E_ControlMethod.Stepped, Message := 'empty retain: Stepped');
AssertTrue(Condition := fbDut.xEnteredManual AND NOT fbDut.xEnteredAuto, Message := 'first call pulses Manual entry');
AssertEquals_UINT(Expected := 0, Actual := afbPump[1].uiRequestModeCalls + afbPump[2].uiRequestModeCalls
                  + afbPump[3].uiRequestModeCalls, Message := 'no mode requests at start');
AssertEquals_UDINT(Expected := 0, Actual := fbSink.udiCount, Message := 'no events at start');
fbDut(stRetain := stRetain);
AssertFalse(Condition := fbDut.xEnteredManual, Message := 'pulse lasts one call');

coUnit.TEST_FINISHED();
