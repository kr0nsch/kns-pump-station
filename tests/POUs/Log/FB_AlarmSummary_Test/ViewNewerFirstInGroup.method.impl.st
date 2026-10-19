coUnit.TEST('AlarmSummary_ViewNewerFirstInGroup');

fbDut.aitfSource[1] := fbSrc;
fbSrc(uiSlots := 3, udiIdBase := 150, itfTime := fbTime);
fbDut(uiSourceCount := 1, itfTime := fbTime, stView := stView);
FOR uiK := 0 TO 2 DO
    fbTime.Advance(tStep := T#1S);
    fbSrc.axIn[uiK] := TRUE;
    fbSrc(itfTime := fbTime);
    fbDut(itfTime := fbTime, stView := stView);
END_FOR
fbTime.Advance(tStep := GVL_Const.ALM_VIEW_PERIOD);
fbDut(itfTime := fbTime, stView := stView);
AssertEquals_UINT(Expected := 3, Actual := stView.uiCount, Message := '3 rows');
AssertEquals_UDINT(Expected := 152, Actual := stView.astRow[1].udiId, Message := 'newest first');
AssertEquals_UDINT(Expected := 151, Actual := stView.astRow[2].udiId, Message := 'middle');
AssertEquals_UDINT(Expected := 150, Actual := stView.astRow[3].udiId, Message := 'oldest last');

coUnit.TEST_FINISHED();
