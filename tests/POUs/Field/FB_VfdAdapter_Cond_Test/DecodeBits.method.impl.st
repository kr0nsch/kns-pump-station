coUnit.TEST('VfdAdapter_DecodeBits');

fbDut.Decode(wStw := GVL_Const.VFD_STW_READY OR GVL_Const.VFD_STW_FAULT OR GVL_Const.VFD_STW_REMOTE,
             uiFact := 0, xSlaveOk := TRUE);
AssertTrue(Condition := fbDut.xCommOk, Message := 'comm ok follows slave ok');
AssertTrue(Condition := fbDut.xReady, Message := 'STW.0 ready');
AssertFalse(Condition := fbDut.xRunning, Message := 'STW.1 not running');
AssertTrue(Condition := fbDut.xFault, Message := 'STW.2 fault');
AssertFalse(Condition := fbDut.xWarning, Message := 'STW.3 no warning');
AssertTrue(Condition := fbDut.xRemote, Message := 'STW.4 remote');

fbDut.Decode(wStw := GVL_Const.VFD_STW_RUNNING OR GVL_Const.VFD_STW_WARNING, uiFact := 0, xSlaveOk := TRUE);
AssertFalse(Condition := fbDut.xReady, Message := 'second word: not ready');
AssertTrue(Condition := fbDut.xRunning, Message := 'second word: running');
AssertFalse(Condition := fbDut.xFault, Message := 'second word: no fault');
AssertTrue(Condition := fbDut.xWarning, Message := 'second word: warning');
AssertFalse(Condition := fbDut.xRemote, Message := 'second word: not remote');

coUnit.TEST_FINISHED();
