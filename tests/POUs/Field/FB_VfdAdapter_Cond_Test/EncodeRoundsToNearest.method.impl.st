coUnit.TEST('VfdAdapter_EncodeRoundsToNearest');

fbDut.Encode(xQReset := FALSE, rSpeedRef_pct := 12.358);
AssertEquals_UINT(Expected := 618, Actual := fbDut.uiFref, Message := '617.9 rounded up');
fbDut.Encode(xQReset := FALSE, rSpeedRef_pct := 12.342);
AssertEquals_UINT(Expected := 617, Actual := fbDut.uiFref, Message := '617.1 rounded down');
fbDut.Encode(xQReset := FALSE, rSpeedRef_pct := 99.995);
AssertEquals_UINT(Expected := 5000, Actual := fbDut.uiFref, Message := '4999.75 rounded up');

coUnit.TEST_FINISHED();
