coUnit.TEST('ScaledClock_ScaleFiftyBracketsRealTime');

fbClock.Update(rTimeScale := R_SCALE_MAX);
ltRa0 := LTIME();
ltSa := fbClock.Now();
ltRa1 := LTIME();
ltPrev := ltSa;
FOR uiI := 1 TO UI_READS DO
    ltCur := fbClock.Now();
    xMono := xMono AND ltCur >= ltPrev;
    ltPrev := ltCur;
END_FOR
ltRb0 := LTIME();
ltSb := fbClock.Now();
ltRb1 := LTIME();
AssertTrue(Condition := xMono AND ltSb >= ltSa, Message := 'k = 50: clock is monotonic');
lrScaled_ns := ULINT_TO_LREAL(LTIME_TO_ULINT(ltSb - ltSa));
lrLow_ns := REAL_TO_LREAL(R_SCALE_MAX) * ULINT_TO_LREAL(LTIME_TO_ULINT(ltRb0 - ltRa1));
lrHigh_ns := REAL_TO_LREAL(R_SCALE_MAX) * ULINT_TO_LREAL(LTIME_TO_ULINT(ltRb1 - ltRa0));
AssertTrue(Condition := lrScaled_ns >= lrLow_ns - LR_ROUND_NS AND lrScaled_ns <= lrHigh_ns + LR_ROUND_NS,
           Message := 'k = 50: clock interval is 50 x system interval');

coUnit.TEST_FINISHED();
