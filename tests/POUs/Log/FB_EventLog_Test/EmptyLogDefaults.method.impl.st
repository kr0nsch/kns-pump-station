coUnit.TEST('EventLog_EmptyLogDefaults');

AssertEquals_UINT(Expected := 0, Actual := fbLog.uiCount, Message := 'no records');
AssertEquals_UDINT(Expected := 0, Actual := fbLog.udiSeqLast, Message := 'no sequence yet');
AssertFalse(Condition := fbLog.GetRecord(uiAge := 0, stRecord => stRec), Message := 'GetRecord on empty log');
AssertEquals_UDINT(Expected := 0, Actual := stRec.udiSeq, Message := 'empty record');
stView.uiPage := 3;
fbLog.FillView(stView := stView);
AssertEquals_UINT(Expected := 1, Actual := stView.uiPageCount, Message := 'one page');
AssertEquals_UINT(Expected := 0, Actual := stView.uiPage, Message := 'page clamped to 0');
AssertEquals_UDINT(Expected := 0, Actual := stView.astRow[1].udiSeq, Message := 'empty row');
stFeed.udiFromSeq := 1;
fbLog.FillFeed(stFeed := stFeed);
AssertEquals_UINT(Expected := 0, Actual := stFeed.uiCount, Message := 'feed empty');
AssertEquals_UDINT(Expected := 1, Actual := stFeed.udiSeqFirst, Message := 'first = last + 1');
AssertEquals_UDINT(Expected := 0, Actual := stFeed.udiSeqLast, Message := 'last 0');
AssertTrue(Condition := fbLog.TakeSnapshot(), Message := 'snapshot of empty log');
AssertEquals_UINT(Expected := 0, Actual := fbLog.SnapshotCount, Message := 'empty snapshot');

coUnit.TEST_FINISHED();
