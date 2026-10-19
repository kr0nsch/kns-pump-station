coUnit.TEST('ControlSelector_PidNotReadyFallsBackToStepped_A4_A7_PMI28');

fbDut(eMode := E_StationMode.Auto, eMethod := E_ControlMethod.LevelPid, xPidReady := FALSE);
AssertTrue(Condition := fbDut.eControlAct = E_ControlAct.Stepped, Message := 'PID not ready: Stepped');
AssertTrue(Condition := fbDut.xStepFallback, Message := 'STEP condition');
fbDut(eMode := E_StationMode.Auto, eMethod := E_ControlMethod.LevelPid, xPidReady := TRUE);
AssertTrue(Condition := fbDut.eControlAct = E_ControlAct.LevelPid, Message := 'PID ready: LevelPid');
AssertFalse(Condition := fbDut.xStepFallback, Message := 'no STEP condition');
fbDut(eMode := E_StationMode.Auto, eMethod := E_ControlMethod.LevelPid, xEmergency := TRUE, xPidReady := FALSE);
AssertTrue(Condition := fbDut.eControlAct = E_ControlAct.Emergency AND fbDut.xStepFallback,
           Message := 'STEP condition independent of higher states (suppression is PRG_Station)');

coUnit.TEST_FINISHED();
