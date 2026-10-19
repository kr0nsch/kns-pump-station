coUnit.TEST('FieldOwen_OwenAiStatusErrorIsNan');

AssertFalse(Condition := PL.F_IsFinite(rIn := F_OwenAiToMa(rValue_pct := 50.0, usiStatus := 253)),
            Message := 'sensor failed: NaN');
AssertFalse(Condition := PL.F_IsFinite(rIn := F_OwenAiToMa(rValue_pct := 0.0, usiStatus := 246)),
            Message := 'data not ready: NaN');
AssertFalse(Condition := PL.F_IsFinite(rIn := F_OwenAiToMa(rValue_pct := 100.0, usiStatus := 252)),
            Message := 'short circuit: NaN');
AssertTrue(Condition := PL.F_IsFinite(rIn := F_OwenAiToMa(rValue_pct := 100.0, usiStatus := 0)),
           Message := 'no error: finite');

coUnit.TEST_FINISHED();
