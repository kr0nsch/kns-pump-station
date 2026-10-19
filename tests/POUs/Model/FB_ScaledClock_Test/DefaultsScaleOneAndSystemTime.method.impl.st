coUnit.TEST('ScaledClock_DefaultsScaleOneAndSystemTime');

AssertEquals_REAL(Expected := 1.0, Actual := fbClock.Scale, Delta := 0.0, Message := 'default scale is 1');
ltR0 := LTIME();
ltNow := fbClock.Now();
ltR1 := LTIME();
AssertTrue(Condition := ltNow >= ltR0 AND ltNow <= ltR1, Message := 'first Now() equals system time');

coUnit.TEST_FINISHED();
