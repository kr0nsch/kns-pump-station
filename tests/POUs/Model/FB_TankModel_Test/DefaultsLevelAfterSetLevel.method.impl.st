coUnit.TEST('TankModel_DefaultsLevelAfterSetLevel');

fbDut(rInflow_m3h := 0.0, rOutflow_m3h := 0.0, lrDt_s := 0.0, rArea_m2 := R_AREA_M2, rOverflow_m := R_OVERFLOW_M);
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.rLevel_m, Delta := 0.0, Message := 'empty by default');
AssertTrue(Condition := fbDut.xIntakeDry, Message := 'empty tank: intake dry');
fbDut.SetLevel(rNewLevel_m := 1.2);
fbDut(rInflow_m3h := 0.0, rOutflow_m3h := 0.0, lrDt_s := 0.0, rArea_m2 := R_AREA_M2, rOverflow_m := R_OVERFLOW_M);
AssertEquals_REAL(Expected := 1.2, Actual := fbDut.rLevel_m, Delta := R_EPS_M, Message := 'level set');
AssertEquals_REAL(Expected := 14.4, Actual := fbDut.rVolume_m3, Delta := 1.0E-4, Message := 'volume');
AssertFalse(Condition := fbDut.xIntakeDry OR fbDut.xOverflow, Message := 'normal state');

coUnit.TEST_FINISHED();
