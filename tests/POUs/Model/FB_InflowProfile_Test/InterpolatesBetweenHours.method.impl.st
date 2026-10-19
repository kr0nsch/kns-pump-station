coUnit.TEST('InflowProfile_InterpolatesBetweenHours');

fbDut(rTimeOfDay_h := 8.5, rAverage_m3h := R_AVG_M3H, arProfile := stCfg.arDailyProfile);
// ref: inflow.profile.at_08h30_m3h
AssertEquals_REAL(Expected := 108.5, Actual := fbDut.rInflow_m3h, Delta := R_EPS, Message := '08:30 -> 108.5 m3/h');
fbDut(rTimeOfDay_h := 8.75, rAverage_m3h := R_AVG_M3H, arProfile := stCfg.arDailyProfile);
AssertEquals_REAL(Expected := 1.525, Actual := fbDut.rFactor, Delta := 1.0E-6, Message := '08:45 factor 1.525');

coUnit.TEST_FINISHED();
