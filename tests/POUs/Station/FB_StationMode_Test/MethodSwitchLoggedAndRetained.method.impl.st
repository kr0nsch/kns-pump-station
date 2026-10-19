coUnit.TEST('StationMode_MethodSwitchLoggedAndRetained_A3_PMI07');

fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.itfEvents := fbSink;

fbDut(stRetain := stRetain);
fbDut(xSetLevelPid := TRUE, stRetain := stRetain);
AssertTrue(Condition := fbDut.eMethod = E_ControlMethod.LevelPid AND stRetain.eMethod = E_ControlMethod.LevelPid,
           Message := 'LevelPid selected and retained in Manual');
AssertTrue(Condition := fbDut.xMethodChanged, Message := 'method change pulse');
AssertTrue(Condition := fbSink.Has(eFind := E_StationEvent.MethodLevelPid), Message := 'event 101004');
fbDut(xSetStepped := TRUE, xSetLevelPid := TRUE, stRetain := stRetain);
AssertTrue(Condition := fbDut.eMethod = E_ControlMethod.Stepped, Message := 'Stepped wins over LevelPid');
AssertTrue(Condition := fbSink.Has(eFind := E_StationEvent.MethodStepped), Message := 'event 101003');
AssertTrue(Condition := fbDut.eMode = E_StationMode.Manual, Message := 'mode unchanged');

coUnit.TEST_FINISHED();
