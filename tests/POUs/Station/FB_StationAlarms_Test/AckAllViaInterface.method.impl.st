coUnit.TEST('StationAlarms_AckAllViaInterface_A15_PMI36');

fbDut.axCond[E_StationAlarm.DRY] := TRUE;
fbDut.axCond[E_StationAlarm.STEP] := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
itfSrc := fbDut;
AssertTrue(Condition := itfSrc.AckAll(), Message := 'something to ack');
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertEquals_WORD(Expected := 0, Actual := fbDut.wAlmUnack, Message := 'all acked');
AssertEquals_WORD(Expected := 16#0082, Actual := fbDut.wAlmActive, Message := 'still active');
AssertFalse(Condition := itfSrc.AckAll(), Message := 'nothing to ack');

coUnit.TEST_FINISHED();
