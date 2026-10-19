// Тело набора вызывает каждый тест каждый цикл, пока многоцикловые тесты не завершатся (TEST_FINISHED)
EventCsvLineFormat();
WritesHeaderAndAllLines();
EmptySnapshotHeaderOnly();
ReadBackMatchesSnapshot();
ErrorOnBadPathReported();
