coUnit.TEST('EventLog_FeedFromSeqOldestFirst');

fbLog.itfTime := fbTime;
FOR uiI := 1 TO 40 DO
    fbLog.LogEvent(eEvent := E_StationEvent.CfgChanged, rValue := UINT_TO_REAL(uiI));
END_FOR
stFeed.udiFromSeq := 5;
fbLog.FillFeed(stFeed := stFeed);
AssertEquals_UINT(Expected := GVL_Const.LOG_FEED_ROWS, Actual := stFeed.uiCount, Message := 'full feed: 32 rows');
AssertEquals_UDINT(Expected := 5, Actual := stFeed.astRow[1].udiSeq, Message := 'row 1 = from');
AssertEquals_UDINT(Expected := 36, Actual := stFeed.astRow[GVL_Const.LOG_FEED_ROWS].udiSeq, Message := 'row 32 = 36');
AssertEquals_UDINT(Expected := 1, Actual := stFeed.udiSeqFirst, Message := 'oldest 1');
AssertEquals_UDINT(Expected := 40, Actual := stFeed.udiSeqLast, Message := 'newest 40');
stFeed.udiFromSeq := 37;
fbLog.FillFeed(stFeed := stFeed);
AssertEquals_UINT(Expected := 4, Actual := stFeed.uiCount, Message := '4 rows from 37');
AssertEquals_UDINT(Expected := 40, Actual := stFeed.astRow[4].udiSeq, Message := 'row 4 = 40');
AssertEquals_UDINT(Expected := 0, Actual := stFeed.astRow[5].udiSeq, Message := 'row 5 cleared');
stFeed.udiFromSeq := 41;
fbLog.FillFeed(stFeed := stFeed);
AssertEquals_UINT(Expected := 0, Actual := stFeed.uiCount, Message := 'nothing new from 41');

coUnit.TEST_FINISHED();
