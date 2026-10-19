coUnit.TEST('EventLog_RingOverwritesOldestAndCounts');

fbLog.itfTime := fbTime;
FOR uiI := 1 TO 205 DO
    fbLog.LogEvent(eEvent := E_StationEvent.CfgChanged, rValue := UINT_TO_REAL(uiI));
END_FOR
AssertEquals_UINT(Expected := GVL_Const.LOG_CAPACITY, Actual := fbLog.uiCount, Message := 'ring full: 200');
AssertEquals_UDINT(Expected := 5, Actual := fbLog.udiOverwritten, Message := '5 overwritten');
AssertEquals_UDINT(Expected := 205, Actual := fbLog.udiSeqLast, Message := 'last sequence 205');
AssertTrue(Condition := fbLog.GetRecord(uiAge := GVL_Const.LOG_CAPACITY - 1, stRecord => stRec),
           Message := 'oldest present');
AssertEquals_UDINT(Expected := 6, Actual := stRec.udiSeq, Message := 'oldest is no. 6');
AssertEquals_REAL(Expected := 6.0, Actual := stRec.rValue, Delta := R_EPS, Message := 'oldest value 6');
fbLog.GetRecord(uiAge := 0, stRecord => stRec);
AssertEquals_UDINT(Expected := 205, Actual := stRec.udiSeq, Message := 'newest is no. 205');
AssertFalse(Condition := fbLog.GetRecord(uiAge := GVL_Const.LOG_CAPACITY, stRecord => stRec),
            Message := 'no record older than capacity');

coUnit.TEST_FINISHED();
