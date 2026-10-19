coUnit.TEST('StormGenerator_DefaultsSeedDayZeroStorms');

fbDut(lrClock_h := 0.0, udiSeed := stCfg.udiSeed, uiStormsPerDayMax := stCfg.uiStormsPerDayMax,
      rPeakMin_m3h := stCfg.rStormPeakMin_m3h, rPeakMax_m3h := stCfg.rStormPeakMax_m3h,
      tDurationMin := stCfg.tStormMin, tDurationMax := stCfg.tStormMax);
AssertEquals_UDINT(Expected := 0, Actual := fbDut.udiDay, Message := 'day 0');
// ref: storms.day0.count, s1_*, s2_*
AssertEquals_UINT(Expected := 2, Actual := fbDut.uiCount, Message := 'two storms on day 0');
AssertEquals_REAL(Expected := 2.758668, Actual := fbDut.astStorm[1].rStart_h, Delta := R_EPS_H, Message := 's1 start');
AssertEquals_TIME(Expected := T#1549386MS, Actual := fbDut.astStorm[1].tDuration, Message := 's1 duration');
AssertEquals_REAL(Expected := 133.930141, Actual := fbDut.astStorm[1].rPeak_m3h, Delta := R_EPS_M3H,
                  Message := 's1 peak');
AssertEquals_REAL(Expected := 4.532258, Actual := fbDut.astStorm[2].rStart_h, Delta := R_EPS_H, Message := 's2 start');
AssertEquals_TIME(Expected := T#3011220MS, Actual := fbDut.astStorm[2].tDuration, Message := 's2 duration');
AssertEquals_REAL(Expected := 193.778092, Actual := fbDut.astStorm[2].rPeak_m3h, Delta := R_EPS_M3H,
                  Message := 's2 peak');
AssertFalse(Condition := fbDut.xActive, Message := 'no storm at 00:00');
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.rInflow_m3h, Delta := 0.0, Message := 'no storm inflow at 00:00');

coUnit.TEST_FINISHED();
