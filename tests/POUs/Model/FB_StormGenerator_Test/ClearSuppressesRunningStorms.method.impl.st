coUnit.TEST('StormGenerator_ClearSuppressesRunningStorms');

fbDut(lrClock_h := 4.6, udiSeed := stCfg.udiSeed, uiStormsPerDayMax := stCfg.uiStormsPerDayMax,
      rPeakMin_m3h := stCfg.rStormPeakMin_m3h, rPeakMax_m3h := stCfg.rStormPeakMax_m3h,
      tDurationMin := stCfg.tStormMin, tDurationMax := stCfg.tStormMax);
AssertTrue(Condition := fbDut.xActive AND fbDut.rInflow_m3h > 0.0, Message := 'day 0 storm 2 running at 4.6 h');
fbDut.StartNow(lrStartAt_h := 4.6, rPeak_m3h := 150.0, tDuration := T#30M);
fbDut.Clear(lrFrom_h := 4.6);
fbDut(lrClock_h := 4.61);
AssertFalse(Condition := fbDut.xActive, Message := 'running storms cleared');
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.rInflow_m3h, Delta := 0.0, Message := 'no inflow after clear');
fbDut(lrClock_h := 28.9);
AssertTrue(Condition := fbDut.xActive AND fbDut.rInflow_m3h > 0.0, Message := 'later storm of day 1 runs');

coUnit.TEST_FINISHED();
