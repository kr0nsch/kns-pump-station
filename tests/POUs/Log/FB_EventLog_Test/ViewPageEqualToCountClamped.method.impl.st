coUnit.TEST('EventLog_ViewPageEqualToCountClamped');

fbLog.itfTime := fbTime;
FOR uiI := 1 TO 45 DO
    fbLog.LogEvent(eEvent := E_StationEvent.CfgChanged, rValue := UINT_TO_REAL(uiI));
END_FOR
stView.uiPage := 3;
fbLog.FillView(stView := stView);
AssertEquals_UINT(Expected := 2, Actual := stView.uiPage, Message := 'page 3 of 3 clamped to 2');
AssertEquals_UDINT(Expected := 5, Actual := stView.astRow[1].udiSeq, Message := 'last page row 1');

coUnit.TEST_FINISHED();
