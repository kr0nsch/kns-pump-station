// Каждый метод-тест вызывается каждый цикл; coUnit сам отмечает завершённые (TEST_FINISHED)
StartsLeadAtStartLevel();
AssistOnOutputHighForTAssistOn();
AssistOnLevelAboveAssistStart();
AssistOffOutputLowForTAssistOff();
AssistNotOffAboveAssistStartLevel();
StopAllAtStopLevel();
TrackWhenLeadNotSpeedAuto();
TrackWhenLeadCommLost();
NotReadyWithoutCommPump();
ReadyAfterCommRecoverDelay();
NotReadyWhenPidManual();
InitFromRunningPumps();
OutputStagingOnlyWhenPidControls();
NanOutputNoStaging();
TimeBackwardsRestartsConfirm();
CommAbsentDuringPowerRestoreNoRecoverDelay();
HoldOutputWhenLeadDropsOut();
