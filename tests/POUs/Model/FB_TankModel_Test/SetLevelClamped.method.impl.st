coUnit.TEST('TankModel_SetLevelClamped');

fbDut(rInflow_m3h := 0.0, rOutflow_m3h := 0.0, lrDt_s := 0.0, rArea_m2 := R_AREA_M2, rOverflow_m := R_OVERFLOW_M);
fbDut.SetLevel(rNewLevel_m := 10.0);
AssertEquals_REAL(Expected := R_OVERFLOW_M, Actual := fbDut.rLevel_m, Delta := R_EPS_M, Message := 'above overflow');
fbDut.SetLevel(rNewLevel_m := -1.0);
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.rLevel_m, Delta := 0.0, Message := 'below zero');
fbDut.SetLevel(rNewLevel_m := 1.5);
uBits.dwValue := 16#7FC00000;
fbDut.SetLevel(rNewLevel_m := uBits.rValue);
AssertEquals_REAL(Expected := 1.5, Actual := fbDut.rLevel_m, Delta := R_EPS_M, Message := 'NaN ignored');

coUnit.TEST_FINISHED();
