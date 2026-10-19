coUnit.TEST('InflowProfile_DefaultsMatchProfilePoints');

fbDut(rTimeOfDay_h := 8.0, rAverage_m3h := R_AVG_M3H, arProfile := stCfg.arDailyProfile);
// ref: inflow.profile.at_08h_m3h
AssertEquals_REAL(Expected := 112.0, Actual := fbDut.rInflow_m3h, Delta := R_EPS, Message := '08:00 -> 112 m3/h');
AssertEquals_REAL(Expected := 1.60, Actual := fbDut.rFactor, Delta := 1.0E-6, Message := '08:00 factor 1.60');
fbDut(rTimeOfDay_h := 3.0, rAverage_m3h := R_AVG_M3H, arProfile := stCfg.arDailyProfile);
// ref: inflow.profile.at_03h_m3h
AssertEquals_REAL(Expected := 26.6, Actual := fbDut.rInflow_m3h, Delta := R_EPS, Message := '03:00 -> 26.6 m3/h');

coUnit.TEST_FINISHED();
