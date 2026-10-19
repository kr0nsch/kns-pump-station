coUnit.TEST('UtcToIso_CenturyLeapDay2000');

AssertEquals_STRING(Expected := '2000-02-29T00:00:00.000Z', Actual := F_UtcToIso(uliUtc_ms := 951782400000),
                    Message := '2000 is a leap year');
AssertEquals_STRING(Expected := '2000-03-01T00:00:00.000Z', Actual := F_UtcToIso(uliUtc_ms := 951868800000),
                    Message := 'next day');

coUnit.TEST_FINISHED();
