coUnit.TEST('TankModel_NoOverflowWhenBalanced');

fbDut.SetLevel(rNewLevel_m := R_OVERFLOW_M);
FOR uiI := 1 TO 6 DO
    fbDut(rInflow_m3h := 150.0, rOutflow_m3h := 150.0, lrDt_s := LR_STEP_S, rArea_m2 := R_AREA_M2,
          rOverflow_m := R_OVERFLOW_M);
END_FOR
AssertEquals_REAL(Expected := R_OVERFLOW_M, Actual := fbDut.rLevel_m, Delta := R_EPS_M,
                  Message := 'level kept at mark');
AssertFalse(Condition := fbDut.xOverflow, Message := 'no overflow when balanced');
AssertEquals_UDINT(Expected := 0, Actual := fbDut.udiOverflow_s, Message := 'no overflow time');

coUnit.TEST_FINISHED();
