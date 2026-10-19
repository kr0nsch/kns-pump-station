coUnit.TEST('StationAlarms_SuppressionReleaseRestartsOnDelay_A15_PMI22_PMI34');

fbDut.axCond[E_StationAlarm.NORES] := TRUE;
fbDut.axSuppress[E_StationAlarm.NORES] := TRUE;
FOR uiStep := 1 TO 150 DO
    fbTime.Advance(tStep := T#100MS);
    fbDut(itfTime := fbTime, stCfg := stCfg);
END_FOR
itfAlm := fbDut.GetAlarm(uiIndex := E_StationAlarm.NORES - 1);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.SuppressedByDesign, Message := 'NORES suppressed for 15 s');
fbDut.axSuppress[E_StationAlarm.NORES] := FALSE;
fbTime.Advance(tStep := T#100MS);
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertEquals_WORD(Expected := 0, Actual := fbDut.wAlmUnack, Message := 'no unacked alarm on suppression release');
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.Normal, Message := 'NORES normal right after release');
fbDut.axCond[E_StationAlarm.NORES] := FALSE;
fbTime.Advance(tStep := T#100MS);
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertEquals_WORD(Expected := 0, Actual := fbDut.wAlmUnack, Message := 'nothing to acknowledge');
AssertTrue(Condition := fbDut.ePrioUnack = PL.E_AlarmPriority.None, Message := 'no unacked priority (no siren)');
// условие держится после снятия подавления — тревога через свою выдержку 10 с
fbDut.axCond[E_StationAlarm.NORES] := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg);
FOR uiStep := 1 TO 99 DO
    fbTime.Advance(tStep := T#100MS);
    fbDut(itfTime := fbTime, stCfg := stCfg);
END_FOR
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.Normal, Message := 'still normal at 9.9 s');
fbTime.Advance(tStep := T#100MS);
fbDut(itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.ActiveUnack, Message := 'NORES after its 10 s delay');

coUnit.TEST_FINISHED();
