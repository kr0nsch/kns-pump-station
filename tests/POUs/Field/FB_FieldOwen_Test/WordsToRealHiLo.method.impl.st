coUnit.TEST('FieldOwen_WordsToRealHiLo');

AssertEquals_REAL(Expected := 20.0, Actual := F_WordsToReal(wHi := 16#41A0, wLo := 16#0000), Delta := R_EPS_MA,
                  Message := '16#41A00000 = 20.0');
AssertEquals_REAL(Expected := -40.0, Actual := F_WordsToReal(wHi := 16#C220, wLo := 16#0000), Delta := R_EPS_MA,
                  Message := '16#C2200000 = -40.0');
AssertEquals_REAL(Expected := 1.5, Actual := F_WordsToReal(wHi := 16#3FC0, wLo := 16#0000), Delta := R_EPS_MA,
                  Message := '16#3FC00000 = 1.5');
AssertTrue(Condition := ABS(F_WordsToReal(wHi := 16#0000, wLo := 16#41A0) - 20.0) > 1.0,
           Message := 'swapped words: not 20.0');

coUnit.TEST_FINISHED();
