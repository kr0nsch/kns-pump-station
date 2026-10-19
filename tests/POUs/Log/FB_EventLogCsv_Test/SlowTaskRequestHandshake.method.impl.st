coUnit.TEST('EventLogCsv_SlowTaskRequestHandshake');

uiPolls := uiPolls + 1;
CASE iStep OF
    0:
        GVL_Log.fbEventLog.itfTime := fbTime;
        FOR uiI := 1 TO 3 DO
            GVL_Log.fbEventLog.LogEvent(eEvent := E_StationEvent.CfgChanged, rValue := UINT_TO_REAL(uiI));
        END_FOR
        GVL_Log.fbEventLog.TakeSnapshot();
        GVL_Log.xExportReq := TRUE;
        PRG_Slow();
        AssertTrue(Condition := GVL_Log.eExportState = E_LogExportState.Writing, Message := 'first export started');
        AssertFalse(Condition := GVL_Log.xExportReq, Message := 'request taken when export starts');
        iStep := 1;
    1:
        PRG_Slow();
        IF GVL_Log.eExportState = E_LogExportState.Done OR GVL_Log.eExportState = E_LogExportState.Error THEN
            AssertTrue(Condition := GVL_Log.eExportState = E_LogExportState.Done, Message := 'first export done');
            AssertEquals_UINT(Expected := 3, Actual := GVL_Log.uiExportLines, Message := 'first export: 3 lines');
            // MainTask видит Done и сразу ставит новый запрос — до следующего цикла SlowTask
            GVL_Log.fbEventLog.LogEvent(eEvent := E_StationEvent.CfgChanged, rValue := 4.0);
            GVL_Log.fbEventLog.LogEvent(eEvent := E_StationEvent.CfgChanged, rValue := 5.0);
            GVL_Log.fbEventLog.TakeSnapshot();
            GVL_Log.xExportReq := TRUE;
            PRG_Slow();
            xSecond := GVL_Log.eExportState = E_LogExportState.Writing;
            AssertTrue(Condition := xSecond, Message := 'request right after Done starts second export');
            AssertFalse(Condition := GVL_Log.xExportReq, Message := 'second request taken');
            iStep := SEL(xSecond, 3, 2);
        END_IF
    2:
        PRG_Slow();
        IF GVL_Log.eExportState = E_LogExportState.Done OR GVL_Log.eExportState = E_LogExportState.Error THEN
            AssertTrue(Condition := GVL_Log.eExportState = E_LogExportState.Done, Message := 'second export done');
            AssertEquals_UINT(Expected := 5, Actual := GVL_Log.uiExportLines, Message := 'second export: 5 lines');
            AssertFalse(Condition := GVL_Log.xExportReq, Message := 'no request left');
            iStep := 3;
        END_IF
END_CASE
IF iStep = 3 OR uiPolls >= POLLS_MAX THEN
    AssertTrue(Condition := iStep = 3, Message := 'handshake finished in time');
    GVL_Log.fbEventLog.itfTime := 0;
    coUnit.TEST_FINISHED();
END_IF
