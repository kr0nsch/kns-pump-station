// Каждый метод-тест вызывается каждый цикл; coUnit сам отмечает завершённые (TEST_FINISHED)
PlcStartDelaysAllRequests();
PowerLossBlocksRequests();
RestoreWaitsTPwrRestart();
SequenceOnePumpPerStep();
StepAdvancesOnTimeoutIfStartFails();
PowerLossDuringSequenceRestarts();
NothingRequiredFinishesImmediately();
SeqRemainCountsDown();
FirstCallIgnoresPowerInput();
