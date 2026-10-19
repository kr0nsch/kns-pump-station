coUnit.TEST('InflowProfile_NegativeFactorGivesZeroInflow');

stCfg.arDailyProfile[10] := -1.0;
fbDut(rTimeOfDay_h := 10.0, rAverage_m3h := R_AVG_M3H, arProfile := stCfg.arDailyProfile);
AssertEquals_REAL(Expected := -1.0, Actual := fbDut.rFactor, Delta := 0.0, Message := 'factor as entered');
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.rInflow_m3h, Delta := 0.0, Message := 'inflow not negative');

coUnit.TEST_FINISHED();
