coUnit.TEST('FieldOwen_Mx210AiLowWordFirst');

AssertEquals_REAL(Expected := 12.0, Actual := F_Mx210AiToMa(wLo := 16#0000, wHi := 16#4248), Delta := R_EPS_MA,
                  Message := '50 % = 12 mA');
AssertEquals_REAL(Expected := 20.0, Actual := F_Mx210AiToMa(wLo := 16#0000, wHi := 16#42C8), Delta := R_EPS_MA,
                  Message := '100 % = 20 mA');
AssertEquals_REAL(Expected := 4.0, Actual := F_Mx210AiToMa(wLo := 16#0000, wHi := 16#0000), Delta := R_EPS_MA,
                  Message := '0 % = 4 mA');

coUnit.TEST_FINISHED();
