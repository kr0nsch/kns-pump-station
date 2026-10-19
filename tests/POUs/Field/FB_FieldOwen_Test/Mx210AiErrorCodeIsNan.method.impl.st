coUnit.TEST('FieldOwen_Mx210AiErrorCodeIsNan');

AssertFalse(Condition := PL.F_IsFinite(rIn := F_Mx210AiToMa(wLo := 16#0000, wHi := 16#FD00)),
            Message := 'sensor break 16#FD: NaN');
AssertFalse(Condition := PL.F_IsFinite(rIn := F_Mx210AiToMa(wLo := 16#1234, wHi := 16#F000)),
            Message := 'invalid value 16#F0: NaN');
AssertFalse(Condition := PL.F_IsFinite(rIn := F_Mx210AiToMa(wLo := 16#FFFF, wHi := 16#FFFF)),
            Message := 'bad calibration 16#FF: NaN');
AssertTrue(Condition := PL.F_IsFinite(rIn := F_Mx210AiToMa(wLo := 16#0000, wHi := 16#EF00)),
           Message := '16#EF: still a number');

coUnit.TEST_FINISHED();
