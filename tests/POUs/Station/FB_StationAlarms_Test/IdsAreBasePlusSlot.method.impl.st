coUnit.TEST('StationAlarms_IdsAreBasePlusSlot_A15');

fbDut(itfTime := fbTime, stCfg := stCfg);
AssertEquals_UINT(Expected := 13, Actual := fbDut.AlarmCount, Message := '13 station alarms');
FOR uiIdx := 0 TO 12 DO
    itfAlm := fbDut.GetAlarm(uiIndex := uiIdx);
    IF itfAlm = 0 THEN
        xIdsOk := FALSE;
    ELSIF itfAlm.Id <> 100001 + UINT_TO_UDINT(uiIdx) THEN
        xIdsOk := FALSE;
    END_IF
END_FOR
AssertTrue(Condition := xIdsOk, Message := 'ids 100001...100013');
itfAlm := fbDut.GetAlarm(uiIndex := E_StationAlarm.ATS - 1);
AssertEquals_UDINT(Expected := 100005, Actual := itfAlm.Id, Message := 'KNS1.ATS = 100005');

coUnit.TEST_FINISHED();
