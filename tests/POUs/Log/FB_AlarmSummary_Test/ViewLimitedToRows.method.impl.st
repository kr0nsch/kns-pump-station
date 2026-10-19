coUnit.TEST('AlarmSummary_ViewLimitedToRows');

FOR uiS := 1 TO 7 DO
    FOR uiK := 0 TO GVL_Const.ALM_SLOT_MAX DO
        afbSrc[uiS].axIn[uiK] := TRUE;
    END_FOR
    afbSrc[uiS](uiSlots := GVL_Const.ALM_SLOT_MAX + 1, udiIdBase := uiS * 100, itfTime := fbTime);
    fbDut.aitfSource[uiS] := afbSrc[uiS];
END_FOR
fbDut(uiSourceCount := 7, itfTime := fbTime, stView := stView);
AssertEquals_UINT(Expected := GVL_Const.ALM_VIEW_ROWS, Actual := stView.uiCount, Message := 'view limited to 50');
AssertEquals_UINT(Expected := 56, Actual := stView.uiActiveTotal, Message := 'total 56');
AssertEquals_UINT(Expected := 56, Actual := fbDut.auiUnack[2], Message := '56 unacked Medium');
AssertTrue(Condition := stView.astRow[GVL_Const.ALM_VIEW_ROWS].udiId <> 0, Message := 'last row filled');

coUnit.TEST_FINISHED();
