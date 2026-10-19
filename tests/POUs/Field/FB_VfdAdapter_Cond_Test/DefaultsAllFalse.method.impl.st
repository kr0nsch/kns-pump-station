coUnit.TEST('VfdAdapter_DefaultsAllFalse');

AssertFalse(Condition := fbDut.xCommOk OR fbDut.xReady OR fbDut.xRunning OR fbDut.xFault OR fbDut.xWarning
                         OR fbDut.xRemote, Message := 'all status outputs FALSE');
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.rSpeedAct_pct, Delta := 0.0, Message := 'speed 0');
AssertEquals_WORD(Expected := 0, Actual := fbDut.wCtw, Message := 'CTW 0');
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiFref, Message := 'FREF 0');

coUnit.TEST_FINISHED();
