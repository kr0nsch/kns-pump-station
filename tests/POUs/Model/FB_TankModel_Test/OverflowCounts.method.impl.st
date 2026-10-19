coUnit.TEST('TankModel_OverflowCounts');

fbDut.SetLevel(rNewLevel_m := 4.5);
FOR uiI := 1 TO UI_STEPS_10MIN DO
    fbDut(rInflow_m3h := 250.0, rOutflow_m3h := 0.0, lrDt_s := LR_STEP_S, rArea_m2 := R_AREA_M2,
          rOverflow_m := R_OVERFLOW_M);
END_FOR
AssertEquals_REAL(Expected := R_OVERFLOW_M, Actual := fbDut.rLevel_m, Delta := R_EPS_M,
                  Message := 'level limited at overflow');
AssertTrue(Condition := fbDut.xOverflow, Message := 'overflow active');
AssertEquals_UDINT(Expected := 590, Actual := fbDut.udiOverflow_s, Message := 'overflow seconds');
fbDut(rInflow_m3h := 100.0, rOutflow_m3h := 150.0, lrDt_s := LR_STEP_S, rArea_m2 := R_AREA_M2,
      rOverflow_m := R_OVERFLOW_M);
AssertFalse(Condition := fbDut.xOverflow, Message := 'overflow stops when pumps exceed inflow');
AssertTrue(Condition := fbDut.rLevel_m < R_OVERFLOW_M, Message := 'level falls');
AssertEquals_UDINT(Expected := 590, Actual := fbDut.udiOverflow_s, Message := 'overflow seconds kept');

coUnit.TEST_FINISHED();
