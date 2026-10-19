coUnit.TEST('StormGenerator_StormCrossingMidnightContinues');

fbDut(lrClock_h := 527.0, udiSeed := stCfg.udiSeed, uiStormsPerDayMax := stCfg.uiStormsPerDayMax,
      rPeakMin_m3h := stCfg.rStormPeakMin_m3h, rPeakMax_m3h := stCfg.rStormPeakMax_m3h,
      tDurationMin := stCfg.tStormMin, tDurationMax := stCfg.tStormMax);
FOR uiK := 1 TO fbDut.uiCount DO
    IF ABS(fbDut.astStorm[uiK].rStart_h - 23.869357) < R_EPS_H THEN
        xFound := TRUE;
        AssertEquals_TIME(Expected := T#2385650MS, Actual := fbDut.astStorm[uiK].tDuration, Message := 'd21 duration');
    END_IF
END_FOR
// ref: storms.midnight_day21.*
AssertTrue(Condition := xFound, Message := 'day 21 storm at 23.8694 h');
fbDut(lrClock_h := 528.25);
AssertEquals_UDINT(Expected := 22, Actual := fbDut.udiDay, Message := 'day 22');
AssertTrue(Condition := fbDut.xActive, Message := 'storm continues after midnight');
AssertEquals_REAL(Expected := 174.999204, Actual := fbDut.rInflow_m3h, Delta := R_EPS_M3H,
                  Message := 'plateau after midnight');

coUnit.TEST_FINISHED();
