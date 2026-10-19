coUnit.TEST('VfdAdapter_NoCommForcesStatusFalseHoldsSpeed');

wAll := GVL_Const.VFD_STW_READY OR GVL_Const.VFD_STW_RUNNING OR GVL_Const.VFD_STW_FAULT
        OR GVL_Const.VFD_STW_WARNING OR GVL_Const.VFD_STW_REMOTE;
fbDut.Decode(wStw := wAll, uiFact := 3750, xSlaveOk := TRUE);
AssertTrue(Condition := fbDut.xReady AND fbDut.xRunning AND fbDut.xFault, Message := 'with comm: bits set');
fbDut.Decode(wStw := wAll, uiFact := 0, xSlaveOk := FALSE);
AssertFalse(Condition := fbDut.xCommOk, Message := 'comm lost');
AssertFalse(Condition := fbDut.xReady OR fbDut.xRunning OR fbDut.xFault OR fbDut.xWarning OR fbDut.xRemote,
            Message := 'status FALSE without comm');
AssertEquals_REAL(Expected := 75.0, Actual := fbDut.rSpeedAct_pct, Delta := R_EPS_PCT, Message := 'speed held');
fbDut.Decode(wStw := GVL_Const.VFD_STW_READY, uiFact := 1000, xSlaveOk := TRUE);
AssertTrue(Condition := fbDut.xCommOk AND fbDut.xReady, Message := 'comm restored');
AssertEquals_REAL(Expected := 20.0, Actual := fbDut.rSpeedAct_pct, Delta := R_EPS_PCT, Message := 'speed follows');

coUnit.TEST_FINISHED();
