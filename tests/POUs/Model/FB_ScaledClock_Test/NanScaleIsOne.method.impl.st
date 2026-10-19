coUnit.TEST('ScaledClock_NanScaleIsOne');

fbClock.Update(rTimeScale := 25.0);
uBits.dwValue := DW_NAN;
fbClock.Update(rTimeScale := uBits.rValue);
AssertEquals_REAL(Expected := 1.0, Actual := fbClock.Scale, Delta := 0.0, Message := 'NaN -> 1');
fbClock.Update(rTimeScale := 25.0);
uBits.dwValue := DW_INF;
fbClock.Update(rTimeScale := uBits.rValue);
AssertEquals_REAL(Expected := 1.0, Actual := fbClock.Scale, Delta := 0.0, Message := '+Inf -> 1');
uBits.dwValue := DW_NEG_INF;
fbClock.Update(rTimeScale := uBits.rValue);
AssertEquals_REAL(Expected := 1.0, Actual := fbClock.Scale, Delta := 0.0, Message := '-Inf -> 1');

coUnit.TEST_FINISHED();
