coUnit.TEST('AlarmSummary_PrioUnackHighestBeforeLower');

fbSrc.astCfg[0].ePriority := PL.E_AlarmPriority.Critical;
fbSrc.astCfg[1].ePriority := PL.E_AlarmPriority.Low;
fbSrc.axIn[0] := TRUE;
fbSrc.axIn[1] := TRUE;
fbSrc(uiSlots := 2, udiIdBase := 160, itfTime := fbTime);
fbDut.aitfSource[1] := fbSrc;
fbDut(uiSourceCount := 1, itfTime := fbTime, stView := stView);
AssertTrue(Condition := fbDut.ePrioUnack = PL.E_AlarmPriority.Critical, Message := 'Critical before Low');

coUnit.TEST_FINISHED();
