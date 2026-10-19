coUnit.TEST('VfdAdapter_EncodeResetBitWhileQReset');

fbDut.Encode(xQReset := TRUE, rSpeedRef_pct := 50.0);
AssertEquals_WORD(Expected := GVL_Const.VFD_CTW_RESET, Actual := fbDut.wCtw, Message := 'reset bit while QReset');
fbDut.Encode(xQReset := FALSE, rSpeedRef_pct := 50.0);
AssertEquals_WORD(Expected := 0, Actual := fbDut.wCtw, Message := 'reset bit cleared');

coUnit.TEST_FINISHED();
