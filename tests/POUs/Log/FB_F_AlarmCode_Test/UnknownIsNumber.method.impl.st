coUnit.TEST('AlarmCode_UnknownIsNumber');

AssertEquals_STRING(Expected := '9999', Actual := F_AlarmCode(udiId := 9999), Message := 'no device 999');
AssertEquals_STRING(Expected := '118', Actual := F_AlarmCode(udiId := 118), Message := 'slot 8');
AssertEquals_STRING(Expected := '100000', Actual := F_AlarmCode(udiId := 100000), Message := 'station slot 0');
AssertEquals_STRING(Expected := '100014', Actual := F_AlarmCode(udiId := 100014), Message := 'station slot 14');
AssertEquals_STRING(Expected := '100101', Actual := F_AlarmCode(udiId := 100101), Message := 'LIC101 slot 1');

coUnit.TEST_FINISHED();
