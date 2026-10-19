coUnit.TEST('UtcToIso_ZeroIsEmpty');

AssertEquals_STRING(Expected := '', Actual := F_UtcToIso(uliUtc_ms := 0), Message := 'no timestamp');

coUnit.TEST_FINISHED();
