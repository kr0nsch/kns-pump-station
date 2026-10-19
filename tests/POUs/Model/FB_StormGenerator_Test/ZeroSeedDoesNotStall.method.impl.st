coUnit.TEST('StormGenerator_ZeroSeedDoesNotStall');

stCfg.udiSeed := 0;
stCfg.uiStormsPerDayMax := GVL_Const.SIM_STORMS_MAX;
fbDut(lrClock_h := 1.0, udiSeed := stCfg.udiSeed, uiStormsPerDayMax := stCfg.uiStormsPerDayMax,
      rPeakMin_m3h := stCfg.rStormPeakMin_m3h, rPeakMax_m3h := stCfg.rStormPeakMax_m3h,
      tDurationMin := stCfg.tStormMin, tDurationMax := stCfg.tStormMax);
// ref: storms.seed0_max4.*
AssertEquals_UINT(Expected := 0, Actual := fbDut.uiCount, Message := 'seed 0 day 0');
fbDut(lrClock_h := 73.0);
AssertEquals_UINT(Expected := 1, Actual := fbDut.uiCount, Message := 'seed 0 day 3');
fbDut(lrClock_h := 121.0);
AssertEquals_UINT(Expected := 4, Actual := fbDut.uiCount, Message := 'seed 0 day 5');

coUnit.TEST_FINISHED();
