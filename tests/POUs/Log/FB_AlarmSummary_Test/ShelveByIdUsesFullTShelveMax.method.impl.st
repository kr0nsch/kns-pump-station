coUnit.TEST('AlarmSummary_ShelveByIdUsesFullTShelveMax');

fbSrc.axIn[0] := TRUE;
fbSrc(uiSlots := 1, udiIdBase := 170, itfTime := fbTime);
fbDut.aitfSource[1] := fbSrc;
fbDut(uiSourceCount := 1, itfTime := fbTime, stView := stView);
AssertTrue(Condition := fbDut.ShelveById(udiId := 170, xShelve := TRUE), Message := 'shelve accepted');
fbSrc(itfTime := fbTime);
fbTime.Advance(tStep := T#1H1S);
fbSrc(itfTime := fbTime);
itfAlm := fbSrc.GetAlarm(uiIndex := 0);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.Shelved, Message := 'still shelved after 1 h');
fbTime.Advance(tStep := T#7H);
fbSrc(itfTime := fbTime);
itfAlm := fbSrc.GetAlarm(uiIndex := 0);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.ActiveUnack, Message := 'expired after 8 h');

coUnit.TEST_FINISHED();
