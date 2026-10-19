// Каждый метод-тест вызывается каждый цикл; coUnit сам отмечает завершённые (TEST_FINISHED)
StartsLeadAtStartLevelAfterConfirm();
NoStartIfLevelDropsDuringConfirm();
StopsAllAtStopLevel();
AssistOnAndOffWithHysteresis();
TwoToZeroAtStopLevel();
DutyMaxOneLimitsToOne();
InitFromRunningPumpsNoStop();
InvalidLevelHoldsState();
BoundaryLevelsInclusive();
DisabledOutputsZeroInitRestores();
TimeBackwardsRestartsConfirm();
