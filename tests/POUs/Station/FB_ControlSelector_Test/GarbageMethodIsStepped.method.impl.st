coUnit.TEST('ControlSelector_GarbageMethodIsStepped_A4');

pRaw := ADR(eBad);
pRaw^ := 5;
fbDut(eMode := E_StationMode.Auto, eMethod := eBad, xPidReady := TRUE);
AssertTrue(Condition := fbDut.eControlAct = E_ControlAct.Stepped, Message := 'garbage method: Stepped');
AssertFalse(Condition := fbDut.xStepFallback, Message := 'garbage method is not LevelPid');

coUnit.TEST_FINISHED();
