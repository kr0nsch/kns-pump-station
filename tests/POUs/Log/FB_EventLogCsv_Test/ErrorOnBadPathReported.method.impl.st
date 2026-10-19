coUnit.TEST('EventLogCsv_ErrorOnBadPathReported');

IF uiPolls = 0 THEN
    fbLog.LogEvent(eEvent := E_StationEvent.PlcStart, rValue := 0.0);
    fbLog.TakeSnapshot();
END_IF
fbCsv(xExecute := TRUE, sFileName := '', fbLog := fbLog);
uiPolls := uiPolls + 1;
IF fbCsv.xDone OR fbCsv.xError OR uiPolls >= POLLS_MAX THEN
    AssertTrue(Condition := fbCsv.xError, Message := 'error reported');
    AssertFalse(Condition := fbCsv.xDone, Message := 'not done');
    AssertTrue(Condition := fbCsv.eState = E_LogExportState.Error, Message := 'state Error');
    AssertTrue(Condition := fbCsv.udiError <> 0, Message := 'CAA File error code');
    AssertEquals_UINT(Expected := 0, Actual := fbCsv.uiLines, Message := 'no lines');
    coUnit.TEST_FINISHED();
END_IF
