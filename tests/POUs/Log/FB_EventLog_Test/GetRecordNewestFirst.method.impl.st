coUnit.TEST('EventLog_GetRecordNewestFirst');

fbLog.itfTime := fbTime;
fbLog.LogEvent(eEvent := E_StationEvent.LeadChanged, rValue := 1.0);
fbLog.LogEvent(eEvent := E_StationEvent.LeadChanged, rValue := 2.0);
fbLog.LogEvent(eEvent := E_StationEvent.LeadChanged, rValue := 3.0);
fbLog.GetRecord(uiAge := 0, stRecord => stRec);
AssertEquals_REAL(Expected := 3.0, Actual := stRec.rValue, Delta := R_EPS, Message := 'age 0 newest');
fbLog.GetRecord(uiAge := 2, stRecord => stRec);
AssertEquals_REAL(Expected := 1.0, Actual := stRec.rValue, Delta := R_EPS, Message := 'age 2 oldest');
AssertFalse(Condition := fbLog.GetRecord(uiAge := 3, stRecord => stRec), Message := 'age 3 absent');
AssertEquals_UDINT(Expected := 0, Actual := stRec.udiSeq, Message := 'absent record is empty');

coUnit.TEST_FINISHED();
