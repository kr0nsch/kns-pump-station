fbCsv(xExecute := GVL_Log.xExportReq, sFileName := GVL_Const.LOG_CSV_FILE, fbLog := GVL_Log.fbEventLog);
GVL_Log.eExportState := fbCsv.eState;
IF fbCsv.xDone OR fbCsv.xError THEN
    GVL_Log.uiExportLines := fbCsv.uiLines;
    GVL_Log.udiExportError := fbCsv.udiError;
    GVL_Log.xExportReq := FALSE;
END_IF
