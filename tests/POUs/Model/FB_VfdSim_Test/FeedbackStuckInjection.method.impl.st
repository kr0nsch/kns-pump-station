coUnit.TEST('VfdSim_FeedbackStuckInjection');

fbDut(xRunCmd := FALSE, xFeedbackStuck := TRUE, itfTime := fbTime);
AssertFalse(Condition := fbDut.xOutputActive, Message := 'drive stopped');
AssertTrue(Condition := fbDut.xRelayRun, Message := 'run relay stuck closed');

coUnit.TEST_FINISHED();
