coUnit.TEST('AlarmSummary_UnshelveById');

fbSrc.axIn[0] := TRUE;
fbSrc(uiSlots := 1, udiIdBase := 170, itfTime := fbTime);
fbDut.aitfSource[1] := fbSrc;
fbDut(uiSourceCount := 1, itfTime := fbTime, stView := stView);
fbDut.ShelveById(udiId := 170, xShelve := TRUE);
fbSrc(itfTime := fbTime);
itfAlm := fbSrc.GetAlarm(uiIndex := 0);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.Shelved, Message := 'shelved');
AssertTrue(Condition := fbDut.ShelveById(udiId := 170, xShelve := FALSE), Message := 'unshelve accepted');
fbSrc(itfTime := fbTime);
itfAlm := fbSrc.GetAlarm(uiIndex := 0);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.ActiveUnack, Message := 'active again');
AssertFalse(Condition := fbDut.ShelveById(udiId := 170, xShelve := FALSE), Message := 'not shelved: FALSE');

coUnit.TEST_FINISHED();
