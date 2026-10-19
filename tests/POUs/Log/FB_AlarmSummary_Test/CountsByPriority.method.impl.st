coUnit.TEST('AlarmSummary_CountsByPriority');

fbSrc1.astCfg[0].ePriority := PL.E_AlarmPriority.Low;
fbSrc1.astCfg[1].ePriority := PL.E_AlarmPriority.Medium;
fbSrc1.astCfg[2].ePriority := PL.E_AlarmPriority.High;
fbSrc1.axIn[0] := TRUE;
fbSrc1.axIn[1] := TRUE;
fbSrc1.axIn[2] := TRUE;
fbSrc1(uiSlots := 3, udiIdBase := 110, itfTime := fbTime);
fbSrc2.astCfg[0].ePriority := PL.E_AlarmPriority.Critical;
fbSrc2.axIn[0] := TRUE;
fbSrc2(uiSlots := 1, udiIdBase := 100001, itfTime := fbTime);
fbSrc2.AckAll();
fbSrc2(itfTime := fbTime);
fbDut.aitfSource[1] := fbSrc1;
fbDut.aitfSource[2] := fbSrc2;
fbDut(uiSourceCount := 2, itfTime := fbTime, stView := stView);
AssertEquals_UINT(Expected := 1, Actual := fbDut.auiActive[1], Message := 'active Low');
AssertEquals_UINT(Expected := 1, Actual := fbDut.auiActive[2], Message := 'active Medium');
AssertEquals_UINT(Expected := 1, Actual := fbDut.auiActive[3], Message := 'active High');
AssertEquals_UINT(Expected := 1, Actual := fbDut.auiActive[4], Message := 'active Critical (acked)');
AssertEquals_UINT(Expected := 1, Actual := fbDut.auiUnack[3], Message := 'unacked High');
AssertEquals_UINT(Expected := 0, Actual := fbDut.auiUnack[4], Message := 'Critical acked');
AssertEquals_UINT(Expected := 4, Actual := stView.uiActiveTotal, Message := '4 alarms not in Normal');

coUnit.TEST_FINISHED();
