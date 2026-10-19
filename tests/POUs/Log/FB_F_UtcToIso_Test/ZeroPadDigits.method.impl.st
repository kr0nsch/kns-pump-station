coUnit.TEST('UtcToIso_ZeroPadDigits');

AssertEquals_STRING(Expected := '007', Actual := F_ZeroPad(udiValue := 7, uiDigits := 3), Message := '7 -> 007');
AssertEquals_STRING(Expected := '12', Actual := F_ZeroPad(udiValue := 12, uiDigits := 2), Message := '12 -> 12');
AssertEquals_STRING(Expected := '2026', Actual := F_ZeroPad(udiValue := 2026, uiDigits := 2), Message := 'no cut');

coUnit.TEST_FINISHED();
