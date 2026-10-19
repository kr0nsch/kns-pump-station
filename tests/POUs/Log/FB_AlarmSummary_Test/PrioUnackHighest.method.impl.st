coUnit.TEST('AlarmSummary_PrioUnackHighest');

fbSrc.astCfg[0].ePriority := PL.E_AlarmPriority.High;
fbSrc.astCfg[1].ePriority := PL.E_AlarmPriority.Medium;
fbSrc.astCfg[2].ePriority := PL.E_AlarmPriority.Critical;
fbSrc.axIn[0] := TRUE;
fbSrc(uiSlots := 3, udiIdBase := 120, itfTime := fbTime);
fbSrc.AckAll();
fbSrc.axIn[1] := TRUE;
fbSrc(itfTime := fbTime);
fbDut.aitfSource[1] := fbSrc;
fbDut(uiSourceCount := 1, itfTime := fbTime, stView := stView);
AssertTrue(Condition := fbDut.ePrioUnack = PL.E_AlarmPriority.Medium, Message := 'highest unacked Medium');
fbSrc.axIn[2] := TRUE;
fbSrc(itfTime := fbTime);
fbDut(itfTime := fbTime, stView := stView);
AssertTrue(Condition := fbDut.ePrioUnack = PL.E_AlarmPriority.Critical, Message := 'highest unacked Critical');

coUnit.TEST_FINISHED();
