coUnit.TEST('ControlSelector_ChangedPulsesOnce_A4');

fbDut(eMode := E_StationMode.Auto, eMethod := E_ControlMethod.Stepped);
AssertTrue(Condition := fbDut.xChanged, Message := 'first call: Manual -> Stepped is a change');
fbDut(eMode := E_StationMode.Auto, eMethod := E_ControlMethod.Stepped);
AssertFalse(Condition := fbDut.xChanged, Message := 'no change, no pulse');
fbDut(eMode := E_StationMode.Auto, eMethod := E_ControlMethod.Stepped, xEmergency := TRUE);
AssertTrue(Condition := fbDut.xChanged AND fbDut.eControlAct = E_ControlAct.Emergency,
           Message := 'Stepped -> Emergency');
fbDut(eMode := E_StationMode.Auto, eMethod := E_ControlMethod.Stepped, xEmergency := TRUE);
AssertFalse(Condition := fbDut.xChanged, Message := 'pulse lasts one call');

coUnit.TEST_FINISHED();
