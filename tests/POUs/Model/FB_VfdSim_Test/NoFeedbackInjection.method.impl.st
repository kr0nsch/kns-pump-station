coUnit.TEST('VfdSim_NoFeedbackInjection');

fbDut(xRunCmd := TRUE, uiFref := UI_FREF_50HZ, itfTime := fbTime);
FOR uiI := 1 TO 10 * UI_1S DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
fbDut.xNoFeedback := TRUE;
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime);
END_FOR
AssertTrue(Condition := fbDut.rFreq_Hz > 0.0 AND fbDut.xOutputActive, Message := 'drive running');
AssertFalse(Condition := fbDut.xRelayRun, Message := 'run relay open (no feedback)');

coUnit.TEST_FINISHED();
