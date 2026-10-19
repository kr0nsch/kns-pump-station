coUnit.TEST('InflowProfile_MeanIsAverage');

FOR uiI := 0 TO UI_SAMPLES - 1 DO
    fbDut(rTimeOfDay_h := UINT_TO_REAL(uiI) * R_SAMPLE_H, rAverage_m3h := R_AVG_M3H, arProfile := stCfg.arDailyProfile);
    rSum := rSum + fbDut.rInflow_m3h;
END_FOR
// ref: inflow.profile.mean_factor (= 1,0)
AssertEquals_REAL(Expected := R_AVG_M3H, Actual := rSum / UINT_TO_REAL(UI_SAMPLES), Delta := 1.0E-3,
                  Message := 'daily mean equals average inflow');

coUnit.TEST_FINISHED();
