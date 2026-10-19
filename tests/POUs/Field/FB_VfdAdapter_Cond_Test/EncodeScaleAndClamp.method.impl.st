coUnit.TEST('VfdAdapter_EncodeScaleAndClamp');

fbDut.Encode(xQReset := FALSE, rSpeedRef_pct := 50.0);
AssertEquals_UINT(Expected := 2500, Actual := fbDut.uiFref, Message := '50 % = 2500');
fbDut.Encode(xQReset := FALSE, rSpeedRef_pct := 12.345);
AssertEquals_UINT(Expected := 617, Actual := fbDut.uiFref, Message := '12.345 % = 617 (rounded)');
fbDut.Encode(xQReset := FALSE, rSpeedRef_pct := 150.0);
AssertEquals_UINT(Expected := 5000, Actual := fbDut.uiFref, Message := 'clamped to 100 %');
fbDut.Encode(xQReset := FALSE, rSpeedRef_pct := -5.0);
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiFref, Message := 'clamped to 0');
fbDut.Encode(xQReset := FALSE, rSpeedRef_pct := 100.0);
AssertEquals_UINT(Expected := 5000, Actual := fbDut.uiFref, Message := '100 % = 5000');

coUnit.TEST_FINISHED();
