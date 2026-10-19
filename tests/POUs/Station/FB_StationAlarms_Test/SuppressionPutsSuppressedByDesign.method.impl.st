coUnit.TEST('StationAlarms_SuppressionPutsSuppressedByDesign_A15_PMI21');

fbDut.axCond[E_StationAlarm.EHL] := TRUE;
fbDut.axSuppress[E_StationAlarm.EHL] := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
itfAlm := fbDut.GetAlarm(uiIndex := E_StationAlarm.EHL - 1);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.SuppressedByDesign, Message := 'EHL suppressed by design');
AssertEquals_WORD(Expected := 16#0001, Actual := fbDut.wAlmShelved, Message := 'bit 0 in wAlmShelved');
AssertEquals_WORD(Expected := 0, Actual := fbDut.wAlmUnack, Message := 'not unacked');
AssertTrue(Condition := fbDut.ePrioUnack = PL.E_AlarmPriority.None, Message := 'no unacked priority');

coUnit.TEST_FINISHED();
