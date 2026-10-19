coUnit.TEST('TankModel_ZeroOrNegativeStepNoChange');

fbDut.SetLevel(rNewLevel_m := 2.0);
fbDut(rInflow_m3h := 250.0, rOutflow_m3h := 0.0, lrDt_s := 0.0, rArea_m2 := R_AREA_M2, rOverflow_m := R_OVERFLOW_M);
AssertEquals_REAL(Expected := 2.0, Actual := fbDut.rLevel_m, Delta := R_EPS_M, Message := 'dt 0');
fbDut(rInflow_m3h := 250.0, rOutflow_m3h := 0.0, lrDt_s := -5.0, rArea_m2 := R_AREA_M2, rOverflow_m := R_OVERFLOW_M);
AssertEquals_REAL(Expected := 2.0, Actual := fbDut.rLevel_m, Delta := R_EPS_M, Message := 'dt < 0');

coUnit.TEST_FINISHED();
