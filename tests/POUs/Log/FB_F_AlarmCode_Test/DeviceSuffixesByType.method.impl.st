coUnit.TEST('AlarmCode_DeviceSuffixesByType');

AssertEquals_STRING(Expected := 'P101.FTS', Actual := F_AlarmCode(udiId := 110), Message := '110');
AssertEquals_STRING(Expected := 'P101.COM', Actual := F_AlarmCode(udiId := 116), Message := '116');
AssertEquals_STRING(Expected := 'P103.SPD', Actual := F_AlarmCode(udiId := 137), Message := '137');
AssertEquals_STRING(Expected := 'V1.FTS', Actual := F_AlarmCode(udiId := 140), Message := '140');
AssertEquals_STRING(Expected := 'LT101.OOR', Actual := F_AlarmCode(udiId := 1015), Message := '1015');
AssertEquals_STRING(Expected := 'LS102.ALM', Actual := F_AlarmCode(udiId := 1020), Message := '1020');
AssertEquals_STRING(Expected := 'LS103.FAIL', Actual := F_AlarmCode(udiId := 1031), Message := '1031');
AssertEquals_STRING(Expected := 'FT202.H', Actual := F_AlarmCode(udiId := 2021), Message := '2021');
AssertEquals_STRING(Expected := 'HS502.ALM', Actual := F_AlarmCode(udiId := 5020), Message := '5020');

coUnit.TEST_FINISHED();
