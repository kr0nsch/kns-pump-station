coUnit.TEST('StormGenerator_DifferentDaysDiffer');

fbDut(lrClock_h := 1.0, udiSeed := stCfg.udiSeed, uiStormsPerDayMax := stCfg.uiStormsPerDayMax,
      rPeakMin_m3h := stCfg.rStormPeakMin_m3h, rPeakMax_m3h := stCfg.rStormPeakMax_m3h,
      tDurationMin := stCfg.tStormMin, tDurationMax := stCfg.tStormMax);
rStartDay0 := fbDut.astStorm[1].rStart_h;
fbDut(lrClock_h := 25.0);
AssertEquals_UDINT(Expected := 1, Actual := fbDut.udiDay, Message := 'day 1');
AssertTrue(Condition := ABS(fbDut.astStorm[1].rStart_h - rStartDay0) > R_EPS_H, Message := 'day 1 differs from day 0');
fbOther(lrClock_h := 1.0, udiSeed := stCfg.udiSeed + 1, uiStormsPerDayMax := stCfg.uiStormsPerDayMax,
        rPeakMin_m3h := stCfg.rStormPeakMin_m3h, rPeakMax_m3h := stCfg.rStormPeakMax_m3h,
        tDurationMin := stCfg.tStormMin, tDurationMax := stCfg.tStormMax);
AssertTrue(Condition := fbOther.uiCount <> 2 OR ABS(fbOther.astStorm[1].rStart_h - rStartDay0) > R_EPS_H,
           Message := 'other seed gives other storms');

coUnit.TEST_FINISHED();
