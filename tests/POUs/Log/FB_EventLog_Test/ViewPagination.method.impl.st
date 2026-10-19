coUnit.TEST('EventLog_ViewPagination');

fbLog.itfTime := fbTime;
FOR uiI := 1 TO 45 DO
    fbLog.LogEvent(eEvent := E_StationEvent.CfgChanged, rValue := UINT_TO_REAL(uiI));
END_FOR
stView.uiPage := 0;
fbLog.FillView(stView := stView);
AssertEquals_UINT(Expected := 3, Actual := stView.uiPageCount, Message := '3 pages');
AssertEquals_UINT(Expected := 45, Actual := stView.uiCount, Message := '45 records');
AssertEquals_UDINT(Expected := 45, Actual := stView.astRow[1].udiSeq, Message := 'page 0 row 1 newest');
AssertEquals_UDINT(Expected := 26, Actual := stView.astRow[GVL_Const.LOG_VIEW_ROWS].udiSeq,
                   Message := 'page 0 last row');
stView.uiPage := 2;
fbLog.FillView(stView := stView);
AssertEquals_UDINT(Expected := 5, Actual := stView.astRow[1].udiSeq, Message := 'page 2 row 1');
AssertEquals_UDINT(Expected := 1, Actual := stView.astRow[5].udiSeq, Message := 'page 2 row 5 oldest');
AssertEquals_UDINT(Expected := 0, Actual := stView.astRow[6].udiSeq, Message := 'page 2 row 6 empty');
stView.uiPage := 7;
fbLog.FillView(stView := stView);
AssertEquals_UINT(Expected := 2, Actual := stView.uiPage, Message := 'page clamped to last');

coUnit.TEST_FINISHED();
