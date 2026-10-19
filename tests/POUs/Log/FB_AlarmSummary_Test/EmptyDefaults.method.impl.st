coUnit.TEST('AlarmSummary_EmptyDefaults');

fbDut(uiSourceCount := 0, itfTime := fbTime, stView := stView);
FOR uiI := 1 TO GVL_Const.ALM_PRIO_COUNT DO
    AssertEquals_UINT(Expected := 0, Actual := fbDut.auiActive[uiI] + fbDut.auiUnack[uiI], Message := 'counters 0');
END_FOR
AssertTrue(Condition := fbDut.ePrioUnack = PL.E_AlarmPriority.None, Message := 'no unacked');
AssertEquals_UINT(Expected := 0, Actual := stView.uiCount, Message := 'empty view');
AssertEquals_UDINT(Expected := 1, Actual := stView.udiRevision, Message := 'view built on first call');

coUnit.TEST_FINISHED();
