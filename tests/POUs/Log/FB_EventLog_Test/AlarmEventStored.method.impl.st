coUnit.TEST('EventLog_AlarmEventStored');

fbLog.itfTime := fbTime;
stEvent.udiId := 110;
stEvent.ePriority := PL.E_AlarmPriority.Medium;
stEvent.eOldState := PL.E_AlarmState.Normal;
stEvent.eNewState := PL.E_AlarmState.ActiveUnack;
stEvent.eReason := PL.E_AlarmEventReason.Activated;
stEvent.rValue := 1.5;
AssertTrue(Condition := fbLog.OnAlarmEvent(stEvent := stEvent), Message := 'sink accepts');
AssertTrue(Condition := fbLog.GetRecord(uiAge := 0, stRecord => stRec), Message := 'record present');
AssertEquals_UDINT(Expected := 1, Actual := stRec.udiSeq, Message := 'first sequence number 1');
AssertTrue(Condition := stRec.eKind = E_EventKind.Alarm, Message := 'kind Alarm');
AssertEquals_UDINT(Expected := 110, Actual := stRec.udiId, Message := 'alarm id');
AssertTrue(Condition := stRec.ePriority = PL.E_AlarmPriority.Medium, Message := 'priority');
AssertTrue(Condition := stRec.eOldState = PL.E_AlarmState.Normal, Message := 'old state');
AssertTrue(Condition := stRec.eNewState = PL.E_AlarmState.ActiveUnack, Message := 'new state');
AssertTrue(Condition := stRec.eReason = PL.E_AlarmEventReason.Activated, Message := 'reason');
AssertEquals_REAL(Expected := 1.5, Actual := stRec.rValue, Delta := R_EPS, Message := 'value');
AssertEquals_LREAL(Expected := LREAL#3600.0, Actual := stRec.lrMono_s, Delta := LR_EPS_S,
                   Message := 'process time 1 h');
AssertTrue(Condition := (stRec.uliUtc_ms = 0) = NOT fbLog.xClockValid, Message := 'UTC 0 only without clock');
AssertEquals_UINT(Expected := 1, Actual := fbLog.uiCount, Message := 'one record');

coUnit.TEST_FINISHED();
