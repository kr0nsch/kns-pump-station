coUnit.TEST('ScaledClock_AdvanceIgnoredOutsideManual');

fbClock.Update(rTimeScale := 1.0);
fbClock.AdvanceL(ltStep := LTIME#1H);
ltR0 := LTIME();
ltNow := fbClock.Now();
ltR1 := LTIME();
AssertTrue(Condition := ltNow >= ltR0 AND ltNow <= ltR1, Message := 'AdvanceL outside manual mode is ignored');

coUnit.TEST_FINISHED();
