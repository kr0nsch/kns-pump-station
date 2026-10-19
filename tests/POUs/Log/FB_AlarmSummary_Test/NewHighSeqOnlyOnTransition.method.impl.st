coUnit.TEST('AlarmSummary_NewHighSeqOnlyOnTransition');

fbSrc.astCfg[0].ePriority := PL.E_AlarmPriority.High;
fbSrc.astCfg[1].ePriority := PL.E_AlarmPriority.Medium;
fbDut.aitfSource[1] := fbSrc;
fbSrc(uiSlots := 2, udiIdBase := 130, itfTime := fbTime);
fbDut(uiSourceCount := 1, itfTime := fbTime, stView := stView);
AssertEquals_UDINT(Expected := 0, Actual := fbDut.udiNewHighSeq, Message := 'nothing yet');
fbSrc.axIn[0] := TRUE;
fbSrc(itfTime := fbTime);
fbDut(itfTime := fbTime, stView := stView);
fbDut(itfTime := fbTime, stView := stView);
AssertEquals_UDINT(Expected := 1, Actual := fbDut.udiNewHighSeq, Message := 'High appeared once');
fbSrc.axIn[1] := TRUE;
fbSrc(itfTime := fbTime);
fbDut(itfTime := fbTime, stView := stView);
AssertEquals_UDINT(Expected := 1, Actual := fbDut.udiNewHighSeq, Message := 'Medium does not count');
fbSrc.axIn[0] := FALSE;
fbSrc(itfTime := fbTime);
fbDut(itfTime := fbTime, stView := stView);
fbSrc.axIn[0] := TRUE;
fbSrc(itfTime := fbTime);
fbDut(itfTime := fbTime, stView := stView);
AssertEquals_UDINT(Expected := 2, Actual := fbDut.udiNewHighSeq, Message := 'High again after return');

coUnit.TEST_FINISHED();
