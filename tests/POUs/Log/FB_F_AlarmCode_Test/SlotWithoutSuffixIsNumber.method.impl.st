coUnit.TEST('AlarmCode_SlotWithoutSuffixIsNumber');

AssertEquals_STRING(Expected := 'LT101.6', Actual := F_AlarmCode(udiId := 1016), Message := 'AI slot 6');
AssertEquals_STRING(Expected := 'LS102.7', Actual := F_AlarmCode(udiId := 1027), Message := 'DI slot 7');

coUnit.TEST_FINISHED();
