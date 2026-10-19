coUnit.TEST('EventLog_SnapshotAfterWrapOldestFirst');

fbLog.itfTime := fbTime;
FOR uiI := 1 TO 205 DO
    fbLog.LogEvent(eEvent := E_StationEvent.CfgChanged, rValue := UINT_TO_REAL(uiI));
END_FOR
AssertTrue(Condition := fbLog.TakeSnapshot(), Message := 'snapshot taken');
AssertEquals_UINT(Expected := GVL_Const.LOG_CAPACITY, Actual := fbLog.SnapshotCount, Message := '200 records');
uiBad := 0;
FOR uiI := 0 TO GVL_Const.LOG_CAPACITY - 1 DO
    fbLog.GetSnapshotRecord(uiIndex := uiI, stRecord => stRec);
    IF stRec.udiSeq <> UINT_TO_UDINT(uiI) + 6 THEN
        uiBad := uiBad + 1;
    END_IF
END_FOR
AssertEquals_UINT(Expected := 0, Actual := uiBad, Message := 'index i holds no. i + 6');
fbLog.GetSnapshotRecord(uiIndex := GVL_Const.LOG_CAPACITY - 1, stRecord => stRec);
AssertEquals_UDINT(Expected := 205, Actual := stRec.udiSeq, Message := 'last index newest');

coUnit.TEST_FINISHED();
