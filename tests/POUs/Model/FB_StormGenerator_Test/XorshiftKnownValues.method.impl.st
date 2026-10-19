coUnit.TEST('StormGenerator_XorshiftKnownValues');

// ref: xorshift.one.x1
AssertEquals_UDINT(Expected := 270369, Actual := DWORD_TO_UDINT(F_Xorshift32(dwState := 1)), Message := 'x(1)');
// ref: xorshift.seed_default.x1, x2
dwX := F_Xorshift32(dwState := 20261016);
AssertEquals_UDINT(Expected := 552152043, Actual := DWORD_TO_UDINT(dwX), Message := 'x1 from default seed');
dwX := F_Xorshift32(dwState := dwX);
AssertEquals_UDINT(Expected := 3072158977, Actual := DWORD_TO_UDINT(dwX), Message := 'x2 from default seed');
AssertEquals_UDINT(Expected := 0, Actual := DWORD_TO_UDINT(F_Xorshift32(dwState := 0)), Message := 'zero stays zero');

coUnit.TEST_FINISHED();
