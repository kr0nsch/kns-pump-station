coUnit.TEST('EventLog_EventRecordSizeIs40');

AssertEquals_UDINT(Expected := 40, Actual := SIZEOF(ST_EventRecord), Message := 'ST_EventRecord 40 bytes');
AssertEquals_UDINT(Expected := 8 + 20 * 40, Actual := SIZEOF(ST_EventView), Message := 'ST_EventView 808 bytes');
AssertEquals_UDINT(Expected := 16 + 32 * 40, Actual := SIZEOF(ST_EventFeed), Message := 'ST_EventFeed 1296 bytes');

coUnit.TEST_FINISHED();
