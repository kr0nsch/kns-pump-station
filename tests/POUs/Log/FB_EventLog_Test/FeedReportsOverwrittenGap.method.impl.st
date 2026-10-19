coUnit.TEST('EventLog_FeedReportsOverwrittenGap');

fbLog.itfTime := fbTime;
FOR uiI := 1 TO 250 DO
    fbLog.LogEvent(eEvent := E_StationEvent.CfgChanged, rValue := UINT_TO_REAL(uiI));
END_FOR
stFeed.udiFromSeq := 10;
fbLog.FillFeed(stFeed := stFeed);
AssertEquals_UDINT(Expected := 51, Actual := stFeed.udiSeqFirst, Message := 'oldest in ring 51');
AssertEquals_UDINT(Expected := 250, Actual := stFeed.udiSeqLast, Message := 'newest 250');
AssertTrue(Condition := stFeed.udiFromSeq < stFeed.udiSeqFirst, Message := 'client sees gap');
AssertEquals_UDINT(Expected := 51, Actual := stFeed.astRow[1].udiSeq, Message := 'feed starts at oldest');
AssertEquals_UDINT(Expected := 50, Actual := fbLog.udiOverwritten, Message := 'overwritten 50');

coUnit.TEST_FINISHED();
