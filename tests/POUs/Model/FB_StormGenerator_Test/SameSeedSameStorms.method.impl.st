coUnit.TEST('StormGenerator_SameSeedSameStorms');

fbDut(lrClock_h := 30.0, udiSeed := stCfg.udiSeed, uiStormsPerDayMax := stCfg.uiStormsPerDayMax,
      rPeakMin_m3h := stCfg.rStormPeakMin_m3h, rPeakMax_m3h := stCfg.rStormPeakMax_m3h,
      tDurationMin := stCfg.tStormMin, tDurationMax := stCfg.tStormMax);
fbOther(lrClock_h := 30.0, udiSeed := stCfg.udiSeed, uiStormsPerDayMax := stCfg.uiStormsPerDayMax,
      rPeakMin_m3h := stCfg.rStormPeakMin_m3h, rPeakMax_m3h := stCfg.rStormPeakMax_m3h,
      tDurationMin := stCfg.tStormMin, tDurationMax := stCfg.tStormMax);
AssertEquals_UDINT(Expected := 1, Actual := fbDut.udiDay, Message := 'day 1');
AssertEquals_UINT(Expected := fbDut.uiCount, Actual := fbOther.uiCount, Message := 'same count');
FOR uiK := 1 TO fbDut.uiCount DO
    AssertEquals_REAL(Expected := fbDut.astStorm[uiK].rStart_h, Actual := fbOther.astStorm[uiK].rStart_h, Delta := 0.0,
                      Message := 'same start');
    AssertEquals_TIME(Expected := fbDut.astStorm[uiK].tDuration, Actual := fbOther.astStorm[uiK].tDuration,
                      Message := 'same duration');
    AssertEquals_REAL(Expected := fbDut.astStorm[uiK].rPeak_m3h, Actual := fbOther.astStorm[uiK].rPeak_m3h,
                      Delta := 0.0,
                      Message := 'same peak');
END_FOR
// ref: storms.day1.*
AssertEquals_UINT(Expected := 2, Actual := fbDut.uiCount, Message := 'two storms on day 1');
AssertEquals_REAL(Expected := 4.801848, Actual := fbDut.astStorm[1].rStart_h, Delta := R_EPS_H,
                  Message := 'd1 s1 start');
AssertEquals_TIME(Expected := T#4034469MS, Actual := fbDut.astStorm[1].tDuration, Message := 'd1 s1 duration');
AssertEquals_REAL(Expected := 209.133103, Actual := fbDut.astStorm[1].rPeak_m3h, Delta := R_EPS_M3H,
                  Message := 'd1 s1 peak');
AssertEquals_REAL(Expected := 0.300672, Actual := fbDut.astStorm[2].rStart_h, Delta := R_EPS_H,
                  Message := 'd1 s2 start');
AssertEquals_TIME(Expected := T#5001626MS, Actual := fbDut.astStorm[2].tDuration, Message := 'd1 s2 duration');
AssertEquals_REAL(Expected := 178.015715, Actual := fbDut.astStorm[2].rPeak_m3h, Delta := R_EPS_M3H,
                  Message := 'd1 s2 peak');

coUnit.TEST_FINISHED();
