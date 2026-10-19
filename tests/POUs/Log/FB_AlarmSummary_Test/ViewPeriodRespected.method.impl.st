coUnit.TEST('AlarmSummary_ViewPeriodRespected');

fbDut.aitfSource[1] := fbSrc;
fbSrc(uiSlots := 1, udiIdBase := 150, itfTime := fbTime);
fbDut(uiSourceCount := 1, itfTime := fbTime, stView := stView);
AssertEquals_UDINT(Expected := 1, Actual := stView.udiRevision, Message := 'first build');
fbSrc.axIn[0] := TRUE;
fbSrc(itfTime := fbTime);
fbTime.Advance(tStep := T#100MS);
fbDut(itfTime := fbTime, stView := stView);
AssertEquals_UDINT(Expected := 1, Actual := stView.udiRevision, Message := 'no rebuild after 100 ms');
AssertEquals_UINT(Expected := 0, Actual := stView.uiCount, Message := 'view not yet updated');
AssertEquals_UINT(Expected := 1, Actual := fbDut.auiUnack[2], Message := 'counters every cycle');
fbTime.Advance(tStep := T#400MS);
fbDut(itfTime := fbTime, stView := stView);
AssertEquals_UDINT(Expected := 2, Actual := stView.udiRevision, Message := 'rebuild after 500 ms');
AssertEquals_UINT(Expected := 1, Actual := stView.uiCount, Message := 'view updated');

coUnit.TEST_FINISHED();
