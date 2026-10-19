coUnit.TEST('ScaledClock_ScaleClampedToMax');

fbClock.Update(rTimeScale := 100.0);
AssertEquals_REAL(Expected := R_SCALE_MAX, Actual := fbClock.Scale, Delta := 0.0, Message := '100 -> 50');
fbClock.Update(rTimeScale := 0.5);
AssertEquals_REAL(Expected := 1.0, Actual := fbClock.Scale, Delta := 0.0, Message := '0.5 -> 1');
fbClock.Update(rTimeScale := -3.0);
AssertEquals_REAL(Expected := 1.0, Actual := fbClock.Scale, Delta := 0.0, Message := '-3 -> 1');
fbClock.Update(rTimeScale := R_SCALE_MAX);
AssertEquals_REAL(Expected := R_SCALE_MAX, Actual := fbClock.Scale, Delta := 0.0, Message := '50 kept');
fbClock.Update(rTimeScale := 25.5);
AssertEquals_REAL(Expected := 25.5, Actual := fbClock.Scale, Delta := 0.0, Message := '25.5 kept');

coUnit.TEST_FINISHED();
