coUnit.TEST('VfdSim_DefaultsReadyAndStopped');

fbDut(itfTime := fbTime);
AssertTrue(Condition := fbDut.xReady AND fbDut.xCommOk, Message := 'ready, comm ok');
AssertEquals_WORD(Expected := GVL_Const.VFD_STW_READY OR GVL_Const.VFD_STW_REMOTE, Actual := fbDut.wStw,
                  Message := 'STW ready + remote');
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiFact, Message := 'FACT 0');
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiFcode, Message := 'no fault code');
AssertFalse(Condition := fbDut.xRelayRun OR fbDut.xRelayFault OR fbDut.xOutputActive, Message := 'relays open');

coUnit.TEST_FINISHED();
