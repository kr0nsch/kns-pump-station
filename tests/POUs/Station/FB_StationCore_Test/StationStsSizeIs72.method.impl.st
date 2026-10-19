coUnit.TEST('StationCore_StationStsSizeIs72_A19');

AssertEquals_UDINT(Expected := 72, Actual := SIZEOF(stSts), Message := 'ST_StationSts must be 72 bytes');

coUnit.TEST_FINISHED();
