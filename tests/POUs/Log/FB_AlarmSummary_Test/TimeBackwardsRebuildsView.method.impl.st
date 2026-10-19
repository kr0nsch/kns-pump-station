coUnit.TEST('AlarmSummary_TimeBackwardsRebuildsView');

fbDut(uiSourceCount := 0, itfTime := fbTime, stView := stView);
fbTime.SetNow(ltValue := LTIME#59M50S);
fbDut(itfTime := fbTime, stView := stView);
AssertEquals_UDINT(Expected := 2, Actual := stView.udiRevision, Message := 'rebuilt at once');
fbTime.Advance(tStep := T#100MS);
fbDut(itfTime := fbTime, stView := stView);
AssertEquals_UDINT(Expected := 2, Actual := stView.udiRevision, Message := 'period counts from new time');

coUnit.TEST_FINISHED();
