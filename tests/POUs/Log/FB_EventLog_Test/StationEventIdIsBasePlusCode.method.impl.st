coUnit.TEST('EventLog_StationEventIdIsBasePlusCode');

fbLog.itfTime := fbTime;
itfSink := fbLog;
AssertTrue(Condition := itfSink.LogEvent(eEvent := E_StationEvent.AtsPumpIn, rValue := 3.0), Message := 'logged');
fbLog.GetRecord(uiAge := 0, stRecord => stRec);
AssertEquals_UDINT(Expected := 101006, Actual := stRec.udiId, Message := '101000 + 6');
AssertTrue(Condition := stRec.eKind = E_EventKind.Station, Message := 'kind Station');
AssertTrue(Condition := stRec.ePriority = PL.E_AlarmPriority.None, Message := 'priority None');
AssertTrue(Condition := stRec.eOldState = PL.E_AlarmState.Normal AND stRec.eNewState = PL.E_AlarmState.Normal,
           Message := 'states Normal');
AssertTrue(Condition := stRec.eReason = PL.E_AlarmEventReason.None, Message := 'reason None');
AssertEquals_REAL(Expected := 3.0, Actual := stRec.rValue, Delta := R_EPS, Message := 'argument: pump 3');

coUnit.TEST_FINISHED();
