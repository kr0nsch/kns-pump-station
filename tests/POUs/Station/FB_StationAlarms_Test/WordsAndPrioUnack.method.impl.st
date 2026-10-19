coUnit.TEST('StationAlarms_WordsAndPrioUnack_A15_PMI36');

fbDut.axCond[E_StationAlarm.EHL] := TRUE;
fbDut.axCond[E_StationAlarm.STEP] := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertEquals_WORD(Expected := 16#0081, Actual := fbDut.wAlmActive, Message := 'EHL bit 0, STEP bit 7 active');
AssertTrue(Condition := fbDut.ePrioUnack = PL.E_AlarmPriority.Critical, Message := 'highest unacked: Critical');
fbDut(wAckReq := 16#0001, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.ePrioUnack = PL.E_AlarmPriority.Low, Message := 'EHL acked: Low remains');

coUnit.TEST_FINISHED();
