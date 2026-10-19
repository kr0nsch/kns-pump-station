coUnit.TEST('EventLog_SnapshotIndependentOfLaterEvents');

fbLog.itfTime := fbTime;
fbLog.LogEvent(eEvent := E_StationEvent.LeadChanged, rValue := 1.0);
fbLog.LogEvent(eEvent := E_StationEvent.LeadChanged, rValue := 2.0);
fbLog.LogEvent(eEvent := E_StationEvent.LeadChanged, rValue := 3.0);
AssertTrue(Condition := fbLog.TakeSnapshot(), Message := 'snapshot taken');
fbLog.LogEvent(eEvent := E_StationEvent.LeadChanged, rValue := 4.0);
fbLog.LogEvent(eEvent := E_StationEvent.LeadChanged, rValue := 5.0);
AssertEquals_UINT(Expected := 3, Actual := fbLog.SnapshotCount, Message := 'snapshot keeps 3 records');
AssertTrue(Condition := fbLog.GetSnapshotRecord(uiIndex := 0, stRecord => stRec), Message := 'index 0');
AssertEquals_UDINT(Expected := 1, Actual := stRec.udiSeq, Message := 'index 0 oldest');
fbLog.GetSnapshotRecord(uiIndex := 2, stRecord => stRec);
AssertEquals_UDINT(Expected := 3, Actual := stRec.udiSeq, Message := 'index 2 newest of snapshot');
AssertFalse(Condition := fbLog.GetSnapshotRecord(uiIndex := 3, stRecord => stRec), Message := 'index 3 absent');

coUnit.TEST_FINISHED();
