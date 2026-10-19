coUnit.TEST('InflowProfile_WrapsAtMidnight');

fbDut(rTimeOfDay_h := 23.5, rAverage_m3h := R_AVG_M3H, arProfile := stCfg.arDailyProfile);
// ref: inflow.profile.at_23h30_factor
AssertEquals_REAL(Expected := 0.625, Actual := fbDut.rFactor, Delta := 1.0E-6, Message := '23:30 factor 0.625');
fbDut(rTimeOfDay_h := 0.25, rAverage_m3h := R_AVG_M3H, arProfile := stCfg.arDailyProfile);
rRef := fbDut.rFactor;
fbDut(rTimeOfDay_h := 24.25, rAverage_m3h := R_AVG_M3H, arProfile := stCfg.arDailyProfile);
AssertEquals_REAL(Expected := rRef, Actual := fbDut.rFactor, Delta := 1.0E-5, Message := '24.25 h = 0.25 h');
fbDut(rTimeOfDay_h := -0.5, rAverage_m3h := R_AVG_M3H, arProfile := stCfg.arDailyProfile);
AssertEquals_REAL(Expected := 0.625, Actual := fbDut.rFactor, Delta := 1.0E-5, Message := '-0.5 h = 23.5 h');

coUnit.TEST_FINISHED();
