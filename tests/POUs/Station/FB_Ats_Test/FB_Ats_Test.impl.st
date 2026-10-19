// Каждый метод-тест вызывается каждый цикл; coUnit сам отмечает завершённые (TEST_FINISHED)
RequestedPumpFaultRaisesAts();
ModeChangeIsNotAts();
PowerLossIsNotAts();
UnderloadTripIsAts();
AtsClearsWhenPumpAvailableAgain();
EventNamesReplacementPump();
LackWhenRequiredExceedsAvailable();
NoReserveWhenOnePumpUnavailable();
ForeignRunningCountsAgainstLack();
UnrequestedOrManualFaultIsNotAts();
TimeBackwardsWindowRestarts();
NoReserveUsesEffectiveDuty();
