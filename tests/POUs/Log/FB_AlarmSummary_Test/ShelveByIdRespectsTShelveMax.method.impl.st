coUnit.TEST('AlarmSummary_ShelveByIdRespectsTShelveMax');

fbSrc.astCfg[0].ePriority := PL.E_AlarmPriority.Critical;
fbSrc.astCfg[0].tShelveMax := T#0S;
fbSrc.astCfg[1].tShelveMax := T#1H;
fbSrc.axIn[0] := TRUE;
fbSrc.axIn[1] := TRUE;
fbSrc(uiSlots := 2, udiIdBase := 160, itfTime := fbTime);
fbDut.aitfSource[1] := fbSrc;
fbDut(uiSourceCount := 1, itfTime := fbTime, stView := stView);
AssertFalse(Condition := fbDut.ShelveById(udiId := 160, xShelve := TRUE), Message := 'tShelveMax 0: rejected');
AssertTrue(Condition := fbDut.ShelveById(udiId := 161, xShelve := TRUE), Message := 'tShelveMax 1 h: accepted');
fbSrc(itfTime := fbTime);
itfAlm := fbSrc.GetAlarm(uiIndex := 1);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.Shelved, Message := '161 shelved');
itfAlm := fbSrc.GetAlarm(uiIndex := 0);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.ActiveUnack, Message := '160 active');
fbTime.Advance(tStep := T#1H1S);
fbSrc(itfTime := fbTime);
itfAlm := fbSrc.GetAlarm(uiIndex := 1);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.ActiveUnack,
           Message := 'shelve expired: active again');

coUnit.TEST_FINISHED();
