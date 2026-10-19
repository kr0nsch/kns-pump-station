coUnit.TEST('StationMode_NoEventSinkIsSafe_A3');

fbDut(stRetain := stRetain);
fbDut(xSetAuto := TRUE, xSetLevelPid := TRUE, stRetain := stRetain);
AssertTrue(Condition := fbDut.eMode = E_StationMode.Auto AND fbDut.eMethod = E_ControlMethod.LevelPid,
           Message := 'mode and method switched without sink');

coUnit.TEST_FINISHED();
