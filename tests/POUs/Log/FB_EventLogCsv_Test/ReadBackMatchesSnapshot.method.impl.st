coUnit.TEST('EventLogCsv_ReadBackMatchesSnapshot');

IF uiPolls = 0 THEN
    fbLog.itfTime := fbTime;
    FOR uiI := 1 TO 12 DO
        fbTime.Advance(tStep := T#1S);
        fbLog.LogEvent(eEvent := E_StationEvent.LeadChanged, rValue := UINT_TO_REAL(uiI));
    END_FOR
    fbLog.TakeSnapshot();
    // ожидаемое содержимое: заголовок и строки снимка
    AppendExpected(sText := GVL_Const.LOG_CSV_HEADER, abBuf := abExp, udiLen := udiExpLen);
    FOR uiI := 1 TO fbLog.SnapshotCount DO
        fbLog.GetSnapshotRecord(uiIndex := uiI - 1, stRecord => stRec);
        AppendExpected(sText := F_EventCsvLine(stRecord := stRec), abBuf := abExp, udiLen := udiExpLen);
    END_FOR
END_IF
uiPolls := uiPolls + 1;
CASE iStep OF
    0:
        fbCsv(xExecute := TRUE, sFileName := 'kns_test_events_read.csv', fbLog := fbLog);
        IF fbCsv.xDone OR fbCsv.xError THEN
            iStep := 1;
        END_IF
    1:
        fbOpen(xExecute := TRUE, sFileName := 'kns_test_events_read.csv', eFileMode := FILE.MODE.MREAD,
               xExclusive := FALSE);
        IF fbOpen.xDone THEN
            iStep := 2;
        ELSIF fbOpen.xError THEN
            xReadError := TRUE;
            iStep := 4;
        END_IF
    2:
        fbRead(xExecute := TRUE, hFile := fbOpen.hFile, pBuffer := ADR(abRead), szBuffer := SIZEOF(abRead),
               udiTimeOut := GVL_Const.LOG_CSV_TIMEOUT_US);
        IF fbRead.xDone OR fbRead.xError THEN
            xReadError := fbRead.xError;
            udiReadLen := TO_UDINT(fbRead.szSize);
            iStep := 3;
        END_IF
    3:
        fbClose(xExecute := TRUE, hFile := fbOpen.hFile);
        IF fbClose.xDone OR fbClose.xError THEN
            iStep := 4;
        END_IF
END_CASE
IF iStep = 4 OR uiPolls >= POLLS_MAX THEN
    AssertTrue(Condition := fbCsv.xDone, Message := 'export done');
    AssertFalse(Condition := xReadError, Message := 'file read back without CAA File error');
    AssertEquals_UDINT(Expected := udiExpLen, Actual := udiReadLen, Message := 'file length = expected');
    udiDiff := 0;
    FOR udiK := 1 TO MIN(udiExpLen, udiReadLen) DO
        IF abRead[udiK - 1] <> abExp[udiK - 1] THEN
            udiDiff := udiDiff + 1;
        END_IF
    END_FOR
    AssertEquals_UDINT(Expected := 0, Actual := udiDiff, Message := 'file bytes = header + snapshot lines');
    AssertTrue(Condition := udiExpLen > 0, Message := 'expected content not empty');
    coUnit.TEST_FINISHED();
END_IF
