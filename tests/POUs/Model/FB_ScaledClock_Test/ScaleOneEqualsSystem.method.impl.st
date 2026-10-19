coUnit.TEST('ScaledClock_ScaleOneEqualsSystem');

fbClock.Update(rTimeScale := 1.0);
ltNow := fbClock.Now();
ltR0 := LTIME();
ltNow := fbClock.Now();
ltR1 := LTIME();
AssertTrue(Condition := ltNow >= ltR0 AND ltNow <= ltR1, Message := 'k = 1: Now() equals LTIME()');
AssertEquals_REAL(Expected := 1.0, Actual := fbClock.Scale, Delta := 0.0, Message := 'scale 1');

coUnit.TEST_FINISHED();
