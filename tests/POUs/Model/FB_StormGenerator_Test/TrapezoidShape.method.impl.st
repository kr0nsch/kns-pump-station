coUnit.TEST('StormGenerator_TrapezoidShape');

stCfg.uiStormsPerDayMax := 0;
fbDut(lrClock_h := 10.0, udiSeed := stCfg.udiSeed, uiStormsPerDayMax := stCfg.uiStormsPerDayMax,
      rPeakMin_m3h := stCfg.rStormPeakMin_m3h, rPeakMax_m3h := stCfg.rStormPeakMax_m3h,
      tDurationMin := stCfg.tStormMin, tDurationMax := stCfg.tStormMax);
fbDut.StartNow(lrStartAt_h := 10.0, rPeak_m3h := 200.0, tDuration := T#1H);
fbDut(lrClock_h := 10.0);
AssertTrue(Condition := fbDut.xActive, Message := 'storm active at start');
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.rInflow_m3h, Delta := R_EPS_M3H, Message := '0 at start');
fbDut(lrClock_h := 10.075);
// ref: storms.shape_d1h_peak200.q_at_4m30s
AssertEquals_REAL(Expected := 100.0, Actual := fbDut.rInflow_m3h, Delta := R_EPS_M3H, Message := 'half of rise');
fbDut(lrClock_h := 10.15);
// ref: storms.shape_d1h_peak200.q_at_9m
AssertEquals_REAL(Expected := 200.0, Actual := fbDut.rInflow_m3h, Delta := R_EPS_M3H, Message := 'end of rise');
fbDut(lrClock_h := 10.5);
// ref: storms.shape_d1h_peak200.q_at_30m
AssertEquals_REAL(Expected := 200.0, Actual := fbDut.rInflow_m3h, Delta := R_EPS_M3H, Message := 'plateau');
fbDut(lrClock_h := 10.825);
// ref: storms.shape_d1h_peak200.q_at_49m30s
AssertEquals_REAL(Expected := 100.0, Actual := fbDut.rInflow_m3h, Delta := R_EPS_M3H, Message := 'half of fall');
fbDut(lrClock_h := 11.0);
// ref: storms.shape_d1h_peak200.q_at_60m
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.rInflow_m3h, Delta := 0.0, Message := '0 at end');
AssertFalse(Condition := fbDut.xActive, Message := 'storm ended');

coUnit.TEST_FINISHED();
