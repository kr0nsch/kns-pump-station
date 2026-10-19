coUnit.TEST('AlarmCode_StationAlarms');

AssertEquals_STRING(Expected := 'KNS1.EHL', Actual := F_AlarmCode(udiId := 100001), Message := '100001');
AssertEquals_STRING(Expected := 'KNS1.ATS', Actual := F_AlarmCode(udiId := 100005), Message := '100005');
AssertEquals_STRING(Expected := 'KNS1.UL3', Actual := F_AlarmCode(udiId := 100012), Message := '100012');
AssertEquals_STRING(Expected := 'KNS1.SIM', Actual := F_AlarmCode(udiId := 100013), Message := '100013');

coUnit.TEST_FINISHED();
