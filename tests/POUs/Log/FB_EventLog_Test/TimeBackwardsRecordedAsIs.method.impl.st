coUnit.TEST('EventLog_TimeBackwardsRecordedAsIs');

fbLog.itfTime := fbTime;
fbLog.LogEvent(eEvent := E_StationEvent.PlcStart, rValue := 0.0);
fbTime.SetNow(ltValue := LTIME#59M50S);
fbLog.LogEvent(eEvent := E_StationEvent.AckAll, rValue := 0.0);
fbLog.GetRecord(uiAge := 0, stRecord => stRec);
AssertEquals_UDINT(Expected := 2, Actual := stRec.udiSeq, Message := 'second record kept');
AssertEquals_LREAL(Expected := LREAL#3590.0, Actual := stRec.lrMono_s, Delta := LR_EPS_S, Message := 'time as given');

coUnit.TEST_FINISHED();
