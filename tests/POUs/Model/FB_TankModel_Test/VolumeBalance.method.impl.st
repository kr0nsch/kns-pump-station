coUnit.TEST('TankModel_VolumeBalance');

fbDut.SetLevel(rNewLevel_m := 1.2);
FOR uiI := 1 TO UI_STEPS_1H DO
    fbDut(rInflow_m3h := 30.0, rOutflow_m3h := 10.0, lrDt_s := LR_STEP_S, rArea_m2 := R_AREA_M2,
          rOverflow_m := R_OVERFLOW_M);
END_FOR
// ref: tank.balance_30_10_1h.level_m
AssertEquals_REAL(Expected := 2.866667, Actual := fbDut.rLevel_m, Delta := R_EPS_M, Message := 'level after 1 h');
AssertEquals_UDINT(Expected := 0, Actual := fbDut.udiOverflow_s, Message := 'no overflow');

coUnit.TEST_FINISHED();
