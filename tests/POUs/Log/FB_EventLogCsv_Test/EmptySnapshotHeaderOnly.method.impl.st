coUnit.TEST('EventLogCsv_EmptySnapshotHeaderOnly');

IF uiPolls = 0 THEN
    fbLog.TakeSnapshot();
END_IF
fbCsv(xExecute := TRUE, sFileName := 'kns_test_events_empty.csv', fbLog := fbLog);
uiPolls := uiPolls + 1;
IF fbCsv.xDone OR fbCsv.xError OR uiPolls >= POLLS_MAX THEN
    AssertTrue(Condition := fbCsv.xDone AND NOT fbCsv.xError, Message := 'header-only export done');
    AssertEquals_UINT(Expected := 0, Actual := fbCsv.uiLines, Message := 'no data lines');
    coUnit.TEST_FINISHED();
END_IF
