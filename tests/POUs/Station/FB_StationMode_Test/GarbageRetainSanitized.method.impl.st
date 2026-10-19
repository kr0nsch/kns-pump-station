coUnit.TEST('StationMode_GarbageRetainSanitized_A3');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.itfEvents := fbSink;

pRaw := ADR(stRetain.eMode);
pRaw^ := 7;
pRaw := ADR(stRetain.eMethod);
pRaw^ := 0;
fbDut(stRetain := stRetain);
AssertTrue(Condition := stRetain.eMode = E_StationMode.Manual, Message := 'garbage mode written back as Manual');
AssertTrue(Condition := stRetain.eMethod = E_ControlMethod.Stepped,
           Message := 'garbage method written back as Stepped');
AssertTrue(Condition := fbDut.eMode = E_StationMode.Manual AND fbDut.eMethod = E_ControlMethod.Stepped,
           Message := 'outputs sanitized');

coUnit.TEST_FINISHED();
