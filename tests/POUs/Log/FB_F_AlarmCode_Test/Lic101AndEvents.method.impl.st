coUnit.TEST('AlarmCode_Lic101AndEvents');

AssertEquals_STRING(Expected := 'LIC101.PVF', Actual := F_AlarmCode(udiId := 100100), Message := '100100');
AssertEquals_STRING(Expected := 'KNS1.E6', Actual := F_AlarmCode(udiId := 101006), Message := '101006');
AssertEquals_STRING(Expected := 'KNS1.E23', Actual := F_AlarmCode(udiId := 101023), Message := '101023');

coUnit.TEST_FINISHED();
