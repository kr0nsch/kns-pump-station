coUnit.TEST('VfdAdapter_DecodeScale5000Is100Pct');

fbDut.Decode(wStw := GVL_Const.VFD_STW_RUNNING, uiFact := 5000, xSlaveOk := TRUE);
AssertEquals_REAL(Expected := 100.0, Actual := fbDut.rSpeedAct_pct, Delta := R_EPS_PCT, Message := '5000 = 100 %');
fbDut.Decode(wStw := GVL_Const.VFD_STW_RUNNING, uiFact := 2500, xSlaveOk := TRUE);
AssertEquals_REAL(Expected := 50.0, Actual := fbDut.rSpeedAct_pct, Delta := R_EPS_PCT, Message := '2500 = 50 %');
fbDut.Decode(wStw := GVL_Const.VFD_STW_RUNNING, uiFact := 1, xSlaveOk := TRUE);
AssertEquals_REAL(Expected := 0.02, Actual := fbDut.rSpeedAct_pct, Delta := R_EPS_PCT, Message := '1 = 0.02 %');

coUnit.TEST_FINISHED();
