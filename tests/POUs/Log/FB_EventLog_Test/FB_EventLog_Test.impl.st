// Тело набора вызывает каждый тест; тест проходит за один вызов
EmptyLogDefaults();
EventRecordSizeIs40();
AlarmEventStored();
StationEventIdIsBasePlusCode();
RingOverwritesOldestAndCounts();
GetRecordNewestFirst();
ViewPagination();
ViewPageEqualToCountClamped();
FeedFromSeqOldestFirst();
FeedReportsOverwrittenGap();
MonoTimeIsProcessTime();
TimeBackwardsRecordedAsIs();
SnapshotIndependentOfLaterEvents();
SnapshotAfterWrapOldestFirst();
