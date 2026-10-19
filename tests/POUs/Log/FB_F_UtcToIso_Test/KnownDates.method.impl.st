coUnit.TEST('UtcToIso_KnownDates');

AssertEquals_STRING(Expected := '2026-10-16T07:41:05.120Z', Actual := F_UtcToIso(uliUtc_ms := 1792136465120),
                    Message := 'regular date');
AssertEquals_STRING(Expected := '2024-02-29T23:59:59.999Z', Actual := F_UtcToIso(uliUtc_ms := 1709251199999),
                    Message := 'leap day, end of day');
AssertEquals_STRING(Expected := '2020-01-01T00:00:00.000Z', Actual := F_UtcToIso(uliUtc_ms := 1577836800000),
                    Message := 'start of year');
AssertEquals_STRING(Expected := '2100-03-01T12:00:00.007Z', Actual := F_UtcToIso(uliUtc_ms := 4107585600007),
                    Message := '2100 is not a leap year');

coUnit.TEST_FINISHED();
