coUnit.TEST('StormGenerator_CountLimitedToMax');

stCfg.uiStormsPerDayMax := UI_MAX_TOO_MANY;
fbDut(lrClock_h := 1.0, udiSeed := stCfg.udiSeed, uiStormsPerDayMax := stCfg.uiStormsPerDayMax,
      rPeakMin_m3h := stCfg.rStormPeakMin_m3h, rPeakMax_m3h := stCfg.rStormPeakMax_m3h,
      tDurationMin := stCfg.tStormMin, tDurationMax := stCfg.tStormMax);
// ref: storms.max4.day0_count
AssertEquals_UINT(Expected := GVL_Const.SIM_STORMS_MAX, Actual := fbDut.uiCount, Message := 'day 0 limited to 4');
fbDut(lrClock_h := 49.0);
// ref: storms.max4.day2_count
AssertEquals_UINT(Expected := GVL_Const.SIM_STORMS_MAX, Actual := fbDut.uiCount, Message := 'day 2 limited to 4');

coUnit.TEST_FINISHED();
