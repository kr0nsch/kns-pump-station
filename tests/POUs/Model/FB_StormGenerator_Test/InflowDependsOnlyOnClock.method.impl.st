coUnit.TEST('StormGenerator_InflowDependsOnlyOnClock');

fbDut(lrClock_h := 4.5, udiSeed := stCfg.udiSeed, uiStormsPerDayMax := stCfg.uiStormsPerDayMax,
      rPeakMin_m3h := stCfg.rStormPeakMin_m3h, rPeakMax_m3h := stCfg.rStormPeakMax_m3h,
      tDurationMin := stCfg.tStormMin, tDurationMax := stCfg.tStormMax);
fbOther(lrClock_h := 5.0, udiSeed := stCfg.udiSeed, uiStormsPerDayMax := stCfg.uiStormsPerDayMax,
      rPeakMin_m3h := stCfg.rStormPeakMin_m3h, rPeakMax_m3h := stCfg.rStormPeakMax_m3h,
      tDurationMin := stCfg.tStormMin, tDurationMax := stCfg.tStormMax);
fbFresh(lrClock_h := 4.6, udiSeed := stCfg.udiSeed, uiStormsPerDayMax := stCfg.uiStormsPerDayMax,
      rPeakMin_m3h := stCfg.rStormPeakMin_m3h, rPeakMax_m3h := stCfg.rStormPeakMax_m3h,
      tDurationMin := stCfg.tStormMin, tDurationMax := stCfg.tStormMax);
FOR uiK := 1 TO UI_STEPS - 1 DO
    fbDut(lrClock_h := 4.5 + UINT_TO_LREAL(uiK) * 0.01);
END_FOR
fbDut(lrClock_h := 5.0);
AssertTrue(Condition := fbDut.rInflow_m3h > 0.0, Message := 'storm running at 5.0 h');
AssertEquals_REAL(Expected := fbOther.rInflow_m3h, Actual := fbDut.rInflow_m3h, Delta := 0.0,
                  Message := 'fine and coarse steps give same inflow');
fbDut(lrClock_h := 4.6);
AssertEquals_REAL(Expected := fbFresh.rInflow_m3h, Actual := fbDut.rInflow_m3h, Delta := 0.0,
                  Message := 'clock back: same inflow as fresh evaluation');

coUnit.TEST_FINISHED();
