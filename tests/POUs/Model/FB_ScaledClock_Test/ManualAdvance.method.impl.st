coUnit.TEST('ScaledClock_ManualAdvance');

fbClock.Update(rTimeScale := R_SCALE_MAX);
fbClock.SetManual(xOn := TRUE, ltStart := LT_MANUAL_START);
AssertEquals_LTIME(Expected := LT_MANUAL_START, Actual := fbClock.Now(), Message := 'manual start');
fbClock.AdvanceL(ltStep := LT_MANUAL_STEP);
AssertEquals_LTIME(Expected := LT_MANUAL_AFTER, Actual := fbClock.Now(), Message := 'manual step');
fbClock.Update(rTimeScale := 1.0);
AssertEquals_LTIME(Expected := LT_MANUAL_AFTER, Actual := fbClock.Now(), Message := 'scale does not move manual time');
ltR0 := LTIME();
fbClock.SetManual(xOn := FALSE, ltStart := LTIME#0S);
ltNow := fbClock.Now();
ltR1 := LTIME();
AssertTrue(Condition := ltNow >= LT_MANUAL_AFTER AND ltNow - LT_MANUAL_AFTER <= ltR1 - ltR0,
           Message := 'manual off continues from manual time');

coUnit.TEST_FINISHED();
