coUnit.TEST('EventLogCsv_WritesHeaderAndAllLines');

IF NOT xStarted THEN
    fbLog.itfTime := fbTime;
    FOR uiI := 1 TO 25 DO
        fbLog.LogEvent(eEvent := E_StationEvent.CfgChanged, rValue := UINT_TO_REAL(uiI));
    END_FOR
    fbLog.TakeSnapshot();
    xStarted := TRUE;
END_IF
fbCsv(xExecute := TRUE, sFileName := 'kns_test_events_all.csv', fbLog := fbLog);
uiPolls := uiPolls + 1;
IF fbCsv.xDone OR fbCsv.xError OR uiPolls >= POLLS_MAX THEN
    AssertTrue(Condition := fbCsv.xDone, Message := 'export done');
    AssertFalse(Condition := fbCsv.xError, Message := 'no error');
    AssertTrue(Condition := fbCsv.eState = E_LogExportState.Done, Message := 'state Done');
    AssertEquals_UINT(Expected := 25, Actual := fbCsv.uiLines, Message := '25 lines');
    AssertEquals_UDINT(Expected := 0, Actual := fbCsv.udiError, Message := 'error code 0');
    coUnit.TEST_FINISHED();
END_IF
