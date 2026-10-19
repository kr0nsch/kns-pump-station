coUnit.TEST('StationAlarms_WordsAndPrioUnack_A15_PMI36');

fbDut.axCond[E_StationAlarm.EHL] := TRUE;
fbDut.axCond[E_StationAlarm.SIM] := TRUE;           // Low без задержки появления
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertEquals_WORD(Expected := 16#1001, Actual := fbDut.wAlmActive, Message := 'EHL bit 0, SIM bit 12');
AssertTrue(Condition := fbDut.ePrioUnack = PL.E_AlarmPriority.Critical, Message := 'highest unacked: Critical');
fbDut(wAckReq := 16#0001, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.ePrioUnack = PL.E_AlarmPriority.Low, Message := 'EHL acked: Low remains');

coUnit.TEST_FINISHED();
