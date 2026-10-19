coUnit.TEST('StationAlarms_GetAlarmIndexOutOfRangeReturnsZero_A15');

fbDut(itfTime := fbTime, stCfg := stCfg);
itfAlm := fbDut.GetAlarm(uiIndex := 13);
AssertTrue(Condition := itfAlm = 0, Message := 'index 13: none');
itfAlm := fbDut.GetAlarm(uiIndex := 65535);
AssertTrue(Condition := itfAlm = 0, Message := 'index 65535: none');

coUnit.TEST_FINISHED();
