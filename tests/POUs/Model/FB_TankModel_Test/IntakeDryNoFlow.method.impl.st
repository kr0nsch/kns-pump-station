coUnit.TEST('TankModel_IntakeDryNoFlow');

fbDut.SetLevel(rNewLevel_m := 0.25);
fbDut(rInflow_m3h := 0.0, rOutflow_m3h := 150.0, lrDt_s := LR_STEP_S, rArea_m2 := R_AREA_M2,
      rOverflow_m := R_OVERFLOW_M);
AssertTrue(Condition := fbDut.xIntakeDry, Message := 'intake dry');
AssertEquals_REAL(Expected := 0.25, Actual := fbDut.rLevel_m, Delta := R_EPS_M, Message := 'no pumping below intake');
FOR uiI := 1 TO UI_STEPS_10MIN DO
    fbDut(rInflow_m3h := 12.0, rOutflow_m3h := 0.0, lrDt_s := LR_STEP_S, rArea_m2 := R_AREA_M2,
          rOverflow_m := R_OVERFLOW_M);
END_FOR
AssertEquals_REAL(Expected := 0.416667, Actual := fbDut.rLevel_m, Delta := R_EPS_M, Message := 'inflow raises level');
AssertFalse(Condition := fbDut.xIntakeDry, Message := 'intake under water again');

coUnit.TEST_FINISHED();
