coUnit.TEST('FieldOwen_OwenAiPctToMa');

AssertEquals_REAL(Expected := 4.0, Actual := F_OwenAiToMa(rValue_pct := 0.0, usiStatus := 0), Delta := R_EPS_MA,
                  Message := '0 % = 4 mA');
AssertEquals_REAL(Expected := 12.0, Actual := F_OwenAiToMa(rValue_pct := 50.0, usiStatus := 0), Delta := R_EPS_MA,
                  Message := '50 % = 12 mA');
AssertEquals_REAL(Expected := 20.0, Actual := F_OwenAiToMa(rValue_pct := 100.0, usiStatus := 0), Delta := R_EPS_MA,
                  Message := '100 % = 20 mA');
AssertEquals_REAL(Expected := 2.4, Actual := F_OwenAiToMa(rValue_pct := -10.0, usiStatus := 0), Delta := R_EPS_MA,
                  Message := '-10 % = 2.4 mA, not clamped');

coUnit.TEST_FINISHED();
