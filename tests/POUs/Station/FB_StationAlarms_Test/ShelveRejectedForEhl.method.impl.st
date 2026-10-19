coUnit.TEST('StationAlarms_ShelveRejectedForEhl_A15_PMI36');

fbDut.axCond[E_StationAlarm.EHL] := TRUE;
fbDut.axCond[E_StationAlarm.DRY] := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
fbDut(wShelveReq := 16#0003, itfTime := fbTime, stCfg := stCfg);
itfAlm := fbDut.GetAlarm(uiIndex := E_StationAlarm.EHL - 1);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.ActiveUnack, Message := 'EHL shelve rejected');
itfAlm := fbDut.GetAlarm(uiIndex := E_StationAlarm.DRY - 1);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.Shelved, Message := 'DRY shelved');
AssertEquals_WORD(Expected := 16#0002, Actual := fbDut.wAlmShelved, Message := 'DRY in wAlmShelved');
fbDut(wShelveReq := 0, wUnshelveReq := 16#0002, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.ActiveUnack, Message := 'DRY unshelved, reannunciated');

coUnit.TEST_FINISHED();
