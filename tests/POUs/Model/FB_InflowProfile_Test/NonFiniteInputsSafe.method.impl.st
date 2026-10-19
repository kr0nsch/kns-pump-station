coUnit.TEST('InflowProfile_NonFiniteInputsSafe');

uBits.dwValue := DW_NAN;
fbDut(rTimeOfDay_h := uBits.rValue, rAverage_m3h := R_AVG_M3H, arProfile := stCfg.arDailyProfile);
AssertTrue(Condition := PL.F_IsFinite(rIn := fbDut.rFactor) AND PL.F_IsFinite(rIn := fbDut.rInflow_m3h),
           Message := 'NaN time: outputs finite');
AssertEquals_REAL(Expected := 0.55, Actual := fbDut.rFactor, Delta := 1.0E-6, Message := 'NaN time -> 0 h');
fbDut(rTimeOfDay_h := 8.0, rAverage_m3h := uBits.rValue, arProfile := stCfg.arDailyProfile);
AssertTrue(Condition := PL.F_IsFinite(rIn := fbDut.rInflow_m3h), Message := 'NaN average: inflow finite');
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.rInflow_m3h, Delta := 0.0, Message := 'NaN average -> 0');

coUnit.TEST_FINISHED();
