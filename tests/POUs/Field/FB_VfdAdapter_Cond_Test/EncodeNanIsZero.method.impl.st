coUnit.TEST('VfdAdapter_EncodeNanIsZero');

fbDut.Encode(xQReset := FALSE, rSpeedRef_pct := 80.0);
AssertEquals_UINT(Expected := 4000, Actual := fbDut.uiFref, Message := 'before NaN: 4000');
uBits.dwValue := 16#7FC00000;      // NaN
fbDut.Encode(xQReset := TRUE, rSpeedRef_pct := uBits.rValue);
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiFref, Message := 'NaN = 0');
AssertEquals_WORD(Expected := GVL_Const.VFD_CTW_RESET, Actual := fbDut.wCtw, Message := 'reset bit with NaN');
uBits.dwValue := 16#7F800000;      // +Inf
fbDut.Encode(xQReset := FALSE, rSpeedRef_pct := uBits.rValue);
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiFref, Message := '+Inf = 0');

coUnit.TEST_FINISHED();
