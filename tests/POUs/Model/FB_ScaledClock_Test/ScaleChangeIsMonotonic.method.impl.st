coUnit.TEST('ScaledClock_ScaleChangeIsMonotonic');

fbClock.Update(rTimeScale := 1.0);
altRead[1] := fbClock.Now();
fbClock.Update(rTimeScale := R_SCALE_MAX);
altRead[2] := fbClock.Now();
fbClock.Update(rTimeScale := 1.0);
altRead[3] := fbClock.Now();
fbClock.Update(rTimeScale := 20.0);
altRead[4] := fbClock.Now();
fbClock.Update(rTimeScale := 20.0);
altRead[5] := fbClock.Now();
fbClock.Update(rTimeScale := 3.5);
altRead[6] := fbClock.Now();
AssertTrue(Condition := altRead[2] >= altRead[1] AND altRead[3] >= altRead[2] AND altRead[4] >= altRead[3]
           AND altRead[5] >= altRead[4] AND altRead[6] >= altRead[5], Message := 'clock never goes back');
AssertEquals_REAL(Expected := 3.5, Actual := fbClock.Scale, Delta := 0.0, Message := 'last scale applied');

coUnit.TEST_FINISHED();
