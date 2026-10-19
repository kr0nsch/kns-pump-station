coUnit.TEST('StationAlarms_AckMaskAcksSlot_A15_PMI36');

fbDut.axCond[E_StationAlarm.DRY] := TRUE;
fbDut.axCond[E_StationAlarm.FLOAT] := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertEquals_WORD(Expected := 16#0022, Actual := fbDut.wAlmUnack, Message := 'DRY and FLOAT unacked');
fbDut(wAckReq := 16#0002, itfTime := fbTime, stCfg := stCfg);
itfAlm := fbDut.GetAlarm(uiIndex := E_StationAlarm.DRY - 1);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.ActiveAck, Message := 'DRY acked');
AssertEquals_WORD(Expected := 16#0020, Actual := fbDut.wAlmUnack, Message := 'FLOAT still unacked');

coUnit.TEST_FINISHED();
