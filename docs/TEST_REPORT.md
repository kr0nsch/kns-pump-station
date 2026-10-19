# Отчёт о тестировании

Результаты юнит-тестов CfUnit (coUnit 1.2.0.0) в CODESYS Control Win V3 и проверок без CODESYS.
Запись «проверено в CODESYS» появляется только после реального прогона. Раздел «Последний прогон
в CODESYS» обновляет `python tools/codesys/cds.py report` по итогам `cds.py test`
(`build/test-results.json`); правки внутри него вручную перезаписываются.

<!-- cds:test-report:begin (раздел обновляет `python tools/codesys/cds.py report`) -->
## Последний прогон в CODESYS

Проверено в CODESYS 3.5.17.30 / CODESYS Control Win V3 (пользовательский процесс) — 2026-10-19 18:01:06. Итог: **все тесты пройдены**.

| Параметр | Значение |
|---|---|
| Дата прогона | 2026-10-19 18:01:06 |
| Коммит | d44f9c7 |
| CODESYS | 3.5.17.30 (профиль `CODESYS V3.5 SP17 Patch 3`) |
| Устройство в проекте | CODESYS Control Win V3 (4096 / 0000 0001 / 3.5.17.30) |
| Рантайм | CODESYS Control Win V3 (пользовательский процесс) |
| Фреймворк тестов | coUnit (CfUnit) 1.2.0.0 |
| Сборка | ошибок 0, предупреждений 0 |
| Способ запуска | `python tools/codesys/cds.py test` |

| Набор | Тестов | Пройдено | Упало | Пропущено | Итог |
|---|---|---|---|---|---|
| `GVL_TestsInfra.fbVfdAdapterCondTest` | 8 | 8 | 0 | 0 | пройдено |
| `GVL_TestsInfra.fbEventLogTest` | 14 | 14 | 0 | 0 | пройдено |
| `GVL_TestsInfra.fbEventLogCsvTest` | 6 | 6 | 0 | 0 | пройдено |
| `GVL_TestsInfra.fbUtcToIsoTest` | 4 | 4 | 0 | 0 | пройдено |
| `GVL_TestsInfra.fbAlarmCodeTest` | 5 | 5 | 0 | 0 | пройдено |
| `GVL_TestsInfra.fbAlarmSummaryTest` | 15 | 15 | 0 | 0 | пройдено |
| `GVL_TestsInfra.fbDeviceAuditTest` | 4 | 4 | 0 | 0 | пройдено |
| `GVL_TestsInfra.fbPlcStartAdoptionTest` | 2 | 2 | 0 | 0 | пройдено |
| `GVL_TestsModel.fbScaledClockTest` | 8 | 8 | 0 | 0 | пройдено |
| `GVL_TestsModel.fbInflowProfileTest` | 6 | 6 | 0 | 0 | пройдено |
| `GVL_TestsModel.fbStormGeneratorTest` | 10 | 10 | 0 | 0 | пройдено |
| `GVL_TestsModel.fbTankModelTest` | 8 | 8 | 0 | 0 | пройдено |
| `GVL_TestsModel.fbHydraulicSolverTest` | 11 | 11 | 0 | 0 | пройдено |
| `GVL_TestsModel.fbVfdSimTest` | 15 | 15 | 0 | 0 | пройдено |
| `GVL_TestsModel.fbPlantModelTest` | 24 | 24 | 0 | 0 | пройдено |
| `GVL_TestsStation.fbStationModeTest` | 10 | 10 | 0 | 0 | пройдено |
| `GVL_TestsStation.fbControlSelectorTest` | 5 | 5 | 0 | 0 | пройдено |
| `GVL_TestsStation.fbLevelControlSteppedTest` | 11 | 11 | 0 | 0 | пройдено |
| `GVL_TestsStation.fbLevelControlPidTest` | 15 | 15 | 0 | 0 | пройдено |
| `GVL_TestsStation.fbPumpRotationTest` | 28 | 28 | 0 | 0 | пройдено |
| `GVL_TestsStation.fbAtsTest` | 13 | 13 | 0 | 0 | пройдено |
| `GVL_TestsStation.fbProtectionsTest` | 21 | 21 | 0 | 0 | пройдено |
| `GVL_TestsStation.fbPumpProtectionTest` | 9 | 9 | 0 | 0 | пройдено |
| `GVL_TestsStation.fbPowerRestoreTest` | 10 | 10 | 0 | 0 | пройдено |
| `GVL_TestsStation.fbVentilationTest` | 4 | 4 | 0 | 0 | пройдено |
| `GVL_TestsStation.fbStationAlarmsTest` | 9 | 9 | 0 | 0 | пройдено |
| `GVL_TestsStation.fbAnnunciatorTest` | 7 | 7 | 0 | 0 | пройдено |
| `GVL_TestsStation.fbStationCfgCheckTest` | 13 | 13 | 0 | 0 | пройдено |
| `GVL_TestsStation.fbStationCoreTest` | 29 | 29 | 0 | 0 | пройдено |
| **Всего** | 324 | 324 | 0 | 0 | **пройдено** |

### Результаты тестов

| Набор | Тест | Итог |
|---|---|---|
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_DefaultsAllFalse` | пройден |
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_DecodeBits` | пройден |
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_DecodeScale5000Is100Pct` | пройден |
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_NoCommForcesStatusFalseHoldsSpeed` | пройден |
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_EncodeResetBitWhileQReset` | пройден |
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_EncodeScaleAndClamp` | пройден |
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_EncodeRoundsToNearest` | пройден |
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_EncodeNanIsZero` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_EmptyLogDefaults` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_EventRecordSizeIs40` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_AlarmEventStored` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_StationEventIdIsBasePlusCode` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_RingOverwritesOldestAndCounts` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_GetRecordNewestFirst` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_ViewPagination` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_ViewPageEqualToCountClamped` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_FeedFromSeqOldestFirst` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_FeedReportsOverwrittenGap` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_MonoTimeIsProcessTime` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_TimeBackwardsRecordedAsIs` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_SnapshotIndependentOfLaterEvents` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_SnapshotAfterWrapOldestFirst` | пройден |
| `GVL_TestsInfra.fbEventLogCsvTest` | `EventLogCsv_EventCsvLineFormat` | пройден |
| `GVL_TestsInfra.fbEventLogCsvTest` | `EventLogCsv_WritesHeaderAndAllLines` | пройден |
| `GVL_TestsInfra.fbEventLogCsvTest` | `EventLogCsv_EmptySnapshotHeaderOnly` | пройден |
| `GVL_TestsInfra.fbEventLogCsvTest` | `EventLogCsv_ReadBackMatchesSnapshot` | пройден |
| `GVL_TestsInfra.fbEventLogCsvTest` | `EventLogCsv_ErrorOnBadPathReported` | пройден |
| `GVL_TestsInfra.fbEventLogCsvTest` | `EventLogCsv_SlowTaskRequestHandshake` | пройден |
| `GVL_TestsInfra.fbUtcToIsoTest` | `UtcToIso_ZeroIsEmpty` | пройден |
| `GVL_TestsInfra.fbUtcToIsoTest` | `UtcToIso_KnownDates` | пройден |
| `GVL_TestsInfra.fbUtcToIsoTest` | `UtcToIso_CenturyLeapDay2000` | пройден |
| `GVL_TestsInfra.fbUtcToIsoTest` | `UtcToIso_ZeroPadDigits` | пройден |
| `GVL_TestsInfra.fbAlarmCodeTest` | `AlarmCode_DeviceSuffixesByType` | пройден |
| `GVL_TestsInfra.fbAlarmCodeTest` | `AlarmCode_StationAlarms` | пройден |
| `GVL_TestsInfra.fbAlarmCodeTest` | `AlarmCode_Lic101AndEvents` | пройден |
| `GVL_TestsInfra.fbAlarmCodeTest` | `AlarmCode_UnknownIsNumber` | пройден |
| `GVL_TestsInfra.fbAlarmCodeTest` | `AlarmCode_SlotWithoutSuffixIsNumber` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_EmptyDefaults` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_SlotMaxMatchesLibrary` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_CountsByPriority` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_PrioUnackHighest` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_PrioUnackHighestBeforeLower` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_NewHighSeqOnlyOnTransition` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_ViewSortedUnackFirst` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_ViewNewerFirstInGroup` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_ViewLimitedToRows` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_ViewPeriodRespected` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_TimeBackwardsRebuildsView` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_AckByIdDeviceStationPid` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_ShelveByIdRespectsTShelveMax` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_ShelveByIdUsesFullTShelveMax` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_UnshelveById` | пройден |
| `GVL_TestsInfra.fbDeviceAuditTest` | `DeviceAudit_NoEventOnFirstCall` | пройден |
| `GVL_TestsInfra.fbDeviceAuditTest` | `DeviceAudit_AuditLogsModeChange` | пройден |
| `GVL_TestsInfra.fbDeviceAuditTest` | `DeviceAudit_NoSinkIsSafe` | пройден |
| `GVL_TestsInfra.fbDeviceAuditTest` | `DeviceAudit_LargeDevNoValueNoOverflow` | пройден |
| `GVL_TestsInfra.fbPlcStartAdoptionTest` | `PlcStartAdoption_AdoptedInGeneratedOrder_A13` | пройден |
| `GVL_TestsInfra.fbPlcStartAdoptionTest` | `PlcStartAdoption_PowerDeviceAfterPumpStopsRunningPump_A13` | пройден |
| `GVL_TestsModel.fbScaledClockTest` | `ScaledClock_DefaultsScaleOneAndSystemTime` | пройден |
| `GVL_TestsModel.fbScaledClockTest` | `ScaledClock_ScaleOneEqualsSystem` | пройден |
| `GVL_TestsModel.fbScaledClockTest` | `ScaledClock_ScaleChangeIsMonotonic` | пройден |
| `GVL_TestsModel.fbScaledClockTest` | `ScaledClock_ScaleClampedToMax` | пройден |
| `GVL_TestsModel.fbScaledClockTest` | `ScaledClock_NanScaleIsOne` | пройден |
| `GVL_TestsModel.fbScaledClockTest` | `ScaledClock_ScaleFiftyBracketsRealTime` | пройден |
| `GVL_TestsModel.fbScaledClockTest` | `ScaledClock_ManualAdvance` | пройден |
| `GVL_TestsModel.fbScaledClockTest` | `ScaledClock_AdvanceIgnoredOutsideManual` | пройден |
| `GVL_TestsModel.fbInflowProfileTest` | `InflowProfile_DefaultsMatchProfilePoints` | пройден |
| `GVL_TestsModel.fbInflowProfileTest` | `InflowProfile_InterpolatesBetweenHours` | пройден |
| `GVL_TestsModel.fbInflowProfileTest` | `InflowProfile_WrapsAtMidnight` | пройден |
| `GVL_TestsModel.fbInflowProfileTest` | `InflowProfile_MeanIsAverage` | пройден |
| `GVL_TestsModel.fbInflowProfileTest` | `InflowProfile_NonFiniteInputsSafe` | пройден |
| `GVL_TestsModel.fbInflowProfileTest` | `InflowProfile_NegativeFactorGivesZeroInflow` | пройден |
| `GVL_TestsModel.fbStormGeneratorTest` | `StormGenerator_XorshiftKnownValues` | пройден |
| `GVL_TestsModel.fbStormGeneratorTest` | `StormGenerator_DefaultsSeedDayZeroStorms` | пройден |
| `GVL_TestsModel.fbStormGeneratorTest` | `StormGenerator_SameSeedSameStorms` | пройден |
| `GVL_TestsModel.fbStormGeneratorTest` | `StormGenerator_DifferentDaysDiffer` | пройден |
| `GVL_TestsModel.fbStormGeneratorTest` | `StormGenerator_TrapezoidShape` | пройден |
| `GVL_TestsModel.fbStormGeneratorTest` | `StormGenerator_StormCrossingMidnightContinues` | пройден |
| `GVL_TestsModel.fbStormGeneratorTest` | `StormGenerator_ClearSuppressesRunningStorms` | пройден |
| `GVL_TestsModel.fbStormGeneratorTest` | `StormGenerator_CountLimitedToMax` | пройден |
| `GVL_TestsModel.fbStormGeneratorTest` | `StormGenerator_ZeroSeedDoesNotStall` | пройден |
| `GVL_TestsModel.fbStormGeneratorTest` | `StormGenerator_InflowDependsOnlyOnClock` | пройден |
| `GVL_TestsModel.fbTankModelTest` | `TankModel_DefaultsLevelAfterSetLevel` | пройден |
| `GVL_TestsModel.fbTankModelTest` | `TankModel_VolumeBalance` | пройден |
| `GVL_TestsModel.fbTankModelTest` | `TankModel_OverflowCounts` | пройден |
| `GVL_TestsModel.fbTankModelTest` | `TankModel_ShortOverflowCounted` | пройден |
| `GVL_TestsModel.fbTankModelTest` | `TankModel_NoOverflowWhenBalanced` | пройден |
| `GVL_TestsModel.fbTankModelTest` | `TankModel_IntakeDryNoFlow` | пройден |
| `GVL_TestsModel.fbTankModelTest` | `TankModel_ZeroOrNegativeStepNoChange` | пройден |
| `GVL_TestsModel.fbTankModelTest` | `TankModel_SetLevelClamped` | пройден |
| `GVL_TestsModel.fbHydraulicSolverTest` | `HydraulicSolver_DefaultsStoppedStaticHead` | пройден |
| `GVL_TestsModel.fbHydraulicSolverTest` | `HydraulicSolver_SinglePumpMatchesReference` | пройден |
| `GVL_TestsModel.fbHydraulicSolverTest` | `HydraulicSolver_ParallelPumpsMatchReference` | пройден |
| `GVL_TestsModel.fbHydraulicSolverTest` | `HydraulicSolver_UnequalSpeedsCheckValveClosed` | пройден |
| `GVL_TestsModel.fbHydraulicSolverTest` | `HydraulicSolver_NoFlowBelowStaticHead` | пройден |
| `GVL_TestsModel.fbHydraulicSolverTest` | `HydraulicSolver_AirLockZeroFlowLowCurrent` | пройден |
| `GVL_TestsModel.fbHydraulicSolverTest` | `HydraulicSolver_ClogReducesFlowRaisesCurrent` | пройден |
| `GVL_TestsModel.fbHydraulicSolverTest` | `HydraulicSolver_ClogWithDryIntakeKeepsDryCurrent` | пройден |
| `GVL_TestsModel.fbHydraulicSolverTest` | `HydraulicSolver_IntakeDryNoFlow` | пройден |
| `GVL_TestsModel.fbHydraulicSolverTest` | `HydraulicSolver_PumpCurrentEdgeCases` | пройден |
| `GVL_TestsModel.fbHydraulicSolverTest` | `HydraulicSolver_NonFiniteSpeedTreatedAsStopped` | пройден |
| `GVL_TestsModel.fbVfdSimTest` | `VfdSim_DefaultsReadyAndStopped` | пройден |
| `GVL_TestsModel.fbVfdSimTest` | `VfdSim_RampToReference` | пройден |
| `GVL_TestsModel.fbVfdSimTest` | `VfdSim_FaultCoastAndResetEdge` | пройден |
| `GVL_TestsModel.fbVfdSimTest` | `VfdSim_OverheatFaultCode` | пройден |
| `GVL_TestsModel.fbVfdSimTest` | `VfdSim_CommLossFreezesRegisters` | пройден |
| `GVL_TestsModel.fbVfdSimTest` | `VfdSim_CommLossWatchdogGoesTo50HzAfter5s` | пройден |
| `GVL_TestsModel.fbVfdSimTest` | `VfdSim_CommRestoredFollowsFref` | пройден |
| `GVL_TestsModel.fbVfdSimTest` | `VfdSim_PowerLossAndBoot` | пройден |
| `GVL_TestsModel.fbVfdSimTest` | `VfdSim_NoFeedbackInjection` | пройден |
| `GVL_TestsModel.fbVfdSimTest` | `VfdSim_FeedbackStuckInjection` | пройден |
| `GVL_TestsModel.fbVfdSimTest` | `VfdSim_LocalRun` | пройден |
| `GVL_TestsModel.fbVfdSimTest` | `VfdSim_LocalRunAtLocalPreset` | пройден |
| `GVL_TestsModel.fbVfdSimTest` | `VfdSim_TimeBackwardsHoldsFrequency` | пройден |
| `GVL_TestsModel.fbVfdSimTest` | `VfdSim_CurrentRegisterScaled` | пройден |
| `GVL_TestsModel.fbVfdSimTest` | `VfdSim_ResetDriveClearsFault` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_DefaultsInitialState` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_MassBalanceNoPumps` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_SteadyStateOnePump87` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_TimeAccelerationConsistency` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_ClearFaultsZeroesFaultsOnly` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_StormNowTrapezoid` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_AiFaultCurrents` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_FloatStuckNormalTripped` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_FanNoFeedback` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_FaultSeqCountsChanges` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_PumpAndStationInjectionsReachIo` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_ButtonsPulse` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_ResetPlantRestoresLevelAndDrives` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_AirLockAndClogCurrents` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_IntakeDryStopsPumping` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_TimeBackwardsHoldsState` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_SetTimeOfDayKeepsDay` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_StepCappedAtMax` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_ResetPlantClearsOverflowTime` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_NanInjectionCountedOnce` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_IntakeEdgeOutflowMatchesTank` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_MassBalanceTwoPumps` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_OverflowTimeResolvedBySubsteps` | пройден |
| `GVL_TestsModel.fbPlantModelTest` | `PlantModel_PerPumpSignalsIsolated` | пройден |
| `GVL_TestsStation.fbStationModeTest` | `StationMode_EmptyRetainStartsManual_A3` | пройден |
| `GVL_TestsStation.fbStationModeTest` | `StationMode_GarbageRetainSanitized_A3` | пройден |
| `GVL_TestsStation.fbStationModeTest` | `StationMode_ManualToAutoRequestsAutoExceptOos_A3_PMI30` | пройден |
| `GVL_TestsStation.fbStationModeTest` | `StationMode_AutoToManualRequestsManual_A3_PMI30` | пройден |
| `GVL_TestsStation.fbStationModeTest` | `StationMode_LocalPumpGetsRememberedMode_A3_PMI31` | пройден |
| `GVL_TestsStation.fbStationModeTest` | `StationMode_ManualWinsOverAutoSameCall_A3` | пройден |
| `GVL_TestsStation.fbStationModeTest` | `StationMode_MethodSwitchLoggedAndRetained_A3_PMI07` | пройден |
| `GVL_TestsStation.fbStationModeTest` | `StationMode_EnteredAutoPulsesOnFirstCallInAuto_A3_A13` | пройден |
| `GVL_TestsStation.fbStationModeTest` | `StationMode_SameModeCommandAcceptedNoRequests_A3` | пройден |
| `GVL_TestsStation.fbStationModeTest` | `StationMode_NoEventSinkIsSafe_A3` | пройден |
| `GVL_TestsStation.fbControlSelectorTest` | `ControlSelector_PrecedenceTable_A4` | пройден |
| `GVL_TestsStation.fbControlSelectorTest` | `ControlSelector_ManualModeAlwaysManual_A4` | пройден |
| `GVL_TestsStation.fbControlSelectorTest` | `ControlSelector_PidNotReadyFallsBackToStepped_A4_A7_PMI28` | пройден |
| `GVL_TestsStation.fbControlSelectorTest` | `ControlSelector_ChangedPulsesOnce_A4` | пройден |
| `GVL_TestsStation.fbControlSelectorTest` | `ControlSelector_GarbageMethodIsStepped_A4` | пройден |
| `GVL_TestsStation.fbLevelControlSteppedTest` | `Stepped_StartsLeadAtStartLevelAfterConfirm_A6_PMI02` | пройден |
| `GVL_TestsStation.fbLevelControlSteppedTest` | `Stepped_NoStartIfLevelDropsDuringConfirm_A6` | пройден |
| `GVL_TestsStation.fbLevelControlSteppedTest` | `Stepped_StopsAllAtStopLevel_A6_PMI02` | пройден |
| `GVL_TestsStation.fbLevelControlSteppedTest` | `Stepped_AssistOnAndOffWithHysteresis_A6_PMI03` | пройден |
| `GVL_TestsStation.fbLevelControlSteppedTest` | `Stepped_TwoToZeroAtStopLevel_A6` | пройден |
| `GVL_TestsStation.fbLevelControlSteppedTest` | `Stepped_DutyMaxOneLimitsToOne_A6` | пройден |
| `GVL_TestsStation.fbLevelControlSteppedTest` | `Stepped_InitFromRunningPumpsNoStop_A6_PMI07` | пройден |
| `GVL_TestsStation.fbLevelControlSteppedTest` | `Stepped_InvalidLevelHoldsState_A6_PMI25` | пройден |
| `GVL_TestsStation.fbLevelControlSteppedTest` | `Stepped_BoundaryLevelsInclusive_A6` | пройден |
| `GVL_TestsStation.fbLevelControlSteppedTest` | `Stepped_DisabledOutputsZeroInitRestores_A6` | пройден |
| `GVL_TestsStation.fbLevelControlSteppedTest` | `Stepped_TimeBackwardsRestartsConfirm_A6` | пройден |
| `GVL_TestsStation.fbLevelControlPidTest` | `LevelPid_StartsLeadAtStartLevel_A7_PMI04` | пройден |
| `GVL_TestsStation.fbLevelControlPidTest` | `LevelPid_AssistOnOutputHighForTAssistOn_A7_PMI05` | пройден |
| `GVL_TestsStation.fbLevelControlPidTest` | `LevelPid_AssistOnLevelAboveAssistStart_A7_PMI05` | пройден |
| `GVL_TestsStation.fbLevelControlPidTest` | `LevelPid_AssistOffOutputLowForTAssistOff_A7_PMI05` | пройден |
| `GVL_TestsStation.fbLevelControlPidTest` | `LevelPid_AssistNotOffAboveAssistStartLevel_A7` | пройден |
| `GVL_TestsStation.fbLevelControlPidTest` | `LevelPid_StopAllAtStopLevel_A7_PMI06` | пройден |
| `GVL_TestsStation.fbLevelControlPidTest` | `LevelPid_TrackWhenLeadNotSpeedAuto_A7_PMI04` | пройден |
| `GVL_TestsStation.fbLevelControlPidTest` | `LevelPid_TrackWhenLeadCommLost_A7_A12_PMI28` | пройден |
| `GVL_TestsStation.fbLevelControlPidTest` | `LevelPid_NotReadyWithoutCommPump_A7_PMI29` | пройден |
| `GVL_TestsStation.fbLevelControlPidTest` | `LevelPid_ReadyAfterCommRecoverDelay_A7_A12_PMI28` | пройден |
| `GVL_TestsStation.fbLevelControlPidTest` | `LevelPid_NotReadyWhenPidManual_A7` | пройден |
| `GVL_TestsStation.fbLevelControlPidTest` | `LevelPid_InitFromRunningPumps_A7_PMI07` | пройден |
| `GVL_TestsStation.fbLevelControlPidTest` | `LevelPid_OutputStagingOnlyWhenPidControls_A7` | пройден |
| `GVL_TestsStation.fbLevelControlPidTest` | `LevelPid_NanOutputNoStaging_A7` | пройден |
| `GVL_TestsStation.fbLevelControlPidTest` | `LevelPid_TimeBackwardsRestartsConfirm_A7` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_RunHoursPicksLeastHours_A8_PMI09` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_TieBreakStartsThenIndex_A8` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_CyclicAdvancesNextLeadRetained_A8_PMI10` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_FixedOrder_A8` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_ReadyBeforeInhibited_A5` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_RunningKeepRoles_A5` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_ForeignRunningReducesRequests_A5_PMI31` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_RequestLimitCapsRequests_A13_PMI34` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_StaggerDelaysSecondStart_A5` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_StopMoreHoursWhenFewerNeeded_A5_PMI03` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_CyclicStopsAssist_A5` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_RequireCommPicksCommPumpAsLead_A5_A12_PMI28` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_LeadSwapWithoutStartStop_A12_PMI28` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_HandoverAfterTMaxContRunWithOverlap_A8_PMI11` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_HandoverRetryWhenNoStandby_A8_PMI11` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_HandoverDisabledInEmergency_A8` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_FaultedPumpLosesRequestImmediately_A9_PMI12_PMI13` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_ResetPumpBecomesStandby_A9_PMI12` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_AdoptKeepsRunningPumpsOnAutoEntry_A3_PMI30` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_AdoptAtPlcStartFromFeedback_A13_PMI35` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_EmergencyRequiresAllThree_A10_PMI20` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_DisabledNoRequestsRolesStandby_A5` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_GarbageNextLeadSanitized_A8` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_StaggerSkippedWhenPreviousDropped_A5_A9` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_TimeBackwardsRestartsStagger_A5` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_HandoverLeadNeedsCommInPid_A5_A8_A12_PMI11` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_CyclicNextLeadFollowsRoleTransfer_A8_PMI10_PMI11` | пройден |
| `GVL_TestsStation.fbPumpRotationTest` | `Rotation_StopKeepsCommPumpInPid_A5_A12_PMI05_PMI28` | пройден |
| `GVL_TestsStation.fbAtsTest` | `Ats_RequestedPumpFaultRaisesAts_A9_PMI12_PMI13` | пройден |
| `GVL_TestsStation.fbAtsTest` | `Ats_ModeChangeIsNotAts_A9_PMI31` | пройден |
| `GVL_TestsStation.fbAtsTest` | `Ats_PowerLossIsNotAts_A9_PMI33` | пройден |
| `GVL_TestsStation.fbAtsTest` | `Ats_UnderloadTripIsAts_A9_A10_PMI15` | пройден |
| `GVL_TestsStation.fbAtsTest` | `Ats_AtsClearsWhenPumpAvailableAgain_A9_PMI12` | пройден |
| `GVL_TestsStation.fbAtsTest` | `Ats_EventNamesReplacementPump_A9_A16_PMI12` | пройден |
| `GVL_TestsStation.fbAtsTest` | `Ats_LackWhenRequiredExceedsAvailable_A9_PMI17` | пройден |
| `GVL_TestsStation.fbAtsTest` | `Ats_NoReserveWhenOnePumpUnavailable_A9_A15_PMI32` | пройден |
| `GVL_TestsStation.fbAtsTest` | `Ats_ForeignRunningCountsAgainstLack_A9_PMI31` | пройден |
| `GVL_TestsStation.fbAtsTest` | `Ats_UnrequestedOrManualFaultIsNotAts_A9_PMI14` | пройден |
| `GVL_TestsStation.fbAtsTest` | `Ats_TimeBackwardsWindowRestarts_A9` | пройден |
| `GVL_TestsStation.fbAtsTest` | `Ats_NoReserveUsesEffectiveDuty_A5_A15_PMI32` | пройден |
| `GVL_TestsStation.fbAtsTest` | `Ats_TripEventNamesReplacementNotTrippedPump_A9_A16_PMI15_PMI16` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_DryRunByFloat_A10_PMI19` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_DryRunByLtLl_A10_PMI18` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_DryRunReleaseAboveL_A10_PMI18` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_DryRunReleaseWithoutLtAfterTDryRelease_A10_PMI19` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_EmergencyByFloatAndByHh_A10_PMI20_PMI23` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_EmergencyReleaseBelowH_A10_PMI20` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_FalseLs103MaskedAfterTLdev_A10_PMI22` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_FalseLs102MaskedAfterTLdev_A10_PMI23` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_Ls102NotTrippedAboveOffMark_A10_PMI24` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_MaskReleasedWhenFloatReturns_A10_PMI22` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_MaskReleasedWhenLtInvalid_A10_PMI25` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_OorLtContradictingFloatMaskedAfterTLdev_A10_A11_PMI26` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_GoodLtContradictingFloatMasksFloat_A10_PMI22` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_LtMaskReleasedAfterTLtRecover_A10_A11_PMI27` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_FloatModeStartsAllOnLs102StopsOnLs103_A11_PMI21_PMI25` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_FloatModeEntryWhilePumpingKeepsPumping_A11_PMI25` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_FloatModeExitAfterTLtRecover_A11_PMI27` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_DryRunAndEmergencyBothDryRunWins_A10` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_FirstCallDoesNotEnterFloatMode_A11_PMI01` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_Ls103NotTrippedBelowOffMark_A10` | пройден |
| `GVL_TestsStation.fbProtectionsTest` | `Protections_TimeBackwardsRestartsLdev_A10` | пройден |
| `GVL_TestsStation.fbPumpProtectionTest` | `PumpProtection_UnderloadTripsAfterTUnderload_A10_PMI15` | пройден |
| `GVL_TestsStation.fbPumpProtectionTest` | `PumpProtection_NoUnderloadBelowMinSpeed_A10` | пройден |
| `GVL_TestsStation.fbPumpProtectionTest` | `PumpProtection_NoUnderloadWhenCurrentInvalid_A10_PMI29` | пройден |
| `GVL_TestsStation.fbPumpProtectionTest` | `PumpProtection_UnderloadLatchedUntilReset_A10_PMI15` | пройден |
| `GVL_TestsStation.fbPumpProtectionTest` | `PumpProtection_ResetClearsLatch_A10_PMI15` | пройден |
| `GVL_TestsStation.fbPumpProtectionTest` | `PumpProtection_DisabledWhenThresholdZero_A10` | пройден |
| `GVL_TestsStation.fbPumpProtectionTest` | `PumpProtection_OverheatInterlockWhileActive_A10_PMI16` | пройден |
| `GVL_TestsStation.fbPumpProtectionTest` | `PumpProtection_CurrentAtThresholdIsNotUnderload_A10` | пройден |
| `GVL_TestsStation.fbPumpProtectionTest` | `PumpProtection_TimeBackwardsRestartsUnderload_A10` | пройден |
| `GVL_TestsStation.fbPowerRestoreTest` | `PowerRestore_PlcStartDelaysAllRequests_A13_PMI01_PMI35` | пройден |
| `GVL_TestsStation.fbPowerRestoreTest` | `PowerRestore_PowerLossBlocksRequests_A13_PMI33` | пройден |
| `GVL_TestsStation.fbPowerRestoreTest` | `PowerRestore_RestoreWaitsTPwrRestart_A13_PMI34` | пройден |
| `GVL_TestsStation.fbPowerRestoreTest` | `PowerRestore_SequenceOnePumpPerStep_A13_PMI34` | пройден |
| `GVL_TestsStation.fbPowerRestoreTest` | `PowerRestore_StepAdvancesOnTimeoutIfStartFails_A13` | пройден |
| `GVL_TestsStation.fbPowerRestoreTest` | `PowerRestore_PowerLossDuringSequenceRestarts_A13_PMI34` | пройден |
| `GVL_TestsStation.fbPowerRestoreTest` | `PowerRestore_NothingRequiredFinishesImmediately_A13` | пройден |
| `GVL_TestsStation.fbPowerRestoreTest` | `PowerRestore_SeqRemainCountsDown_A13_PMI34` | пройден |
| `GVL_TestsStation.fbPowerRestoreTest` | `PowerRestore_FirstCallIgnoresPowerInput_A13_PMI01` | пройден |
| `GVL_TestsStation.fbPowerRestoreTest` | `PowerRestore_TimeBackwardsRestartsDelay_A13` | пройден |
| `GVL_TestsStation.fbVentilationTest` | `Ventilation_RunsOnGasDoorTemp_A17_PMI38` | пройден |
| `GVL_TestsStation.fbVentilationTest` | `Ventilation_OverrunAfterConditionsClear_A17_PMI38` | пройден |
| `GVL_TestsStation.fbVentilationTest` | `Ventilation_FireInterlocksAndStops_A17_PMI38` | пройден |
| `GVL_TestsStation.fbVentilationTest` | `Ventilation_TimeBackwardsRestartsOverrun_A17` | пройден |
| `GVL_TestsStation.fbStationAlarmsTest` | `StationAlarms_IdsAreBasePlusSlot_A15` | пройден |
| `GVL_TestsStation.fbStationAlarmsTest` | `StationAlarms_SuppressionPutsSuppressedByDesign_A15_PMI21` | пройден |
| `GVL_TestsStation.fbStationAlarmsTest` | `StationAlarms_AckMaskAcksSlot_A15_PMI36` | пройден |
| `GVL_TestsStation.fbStationAlarmsTest` | `StationAlarms_AckAllViaInterface_A15_PMI36` | пройден |
| `GVL_TestsStation.fbStationAlarmsTest` | `StationAlarms_GetAlarmIndexOutOfRangeReturnsZero_A15` | пройден |
| `GVL_TestsStation.fbStationAlarmsTest` | `StationAlarms_WordsAndPrioUnack_A15_PMI36` | пройден |
| `GVL_TestsStation.fbStationAlarmsTest` | `StationAlarms_ShelveRejectedForEhl_A15_PMI36` | пройден |
| `GVL_TestsStation.fbStationAlarmsTest` | `StationAlarms_OnDelayFromCfg_A15_PMI17` | пройден |
| `GVL_TestsStation.fbStationAlarmsTest` | `StationAlarms_TimeBackwardsOnDelayRestarts_A15` | пройден |
| `GVL_TestsStation.fbAnnunciatorTest` | `Annunciator_HornOnNewHighUnack_A14_PMI36` | пройден |
| `GVL_TestsStation.fbAnnunciatorTest` | `Annunciator_SilenceStopsHornUntilNextNew_A14_PMI36` | пройден |
| `GVL_TestsStation.fbAnnunciatorTest` | `Annunciator_HornOffWhenAllAcked_A14_PMI36` | пройден |
| `GVL_TestsStation.fbAnnunciatorTest` | `Annunciator_LampBlinksAt1Hz_A14_PMI36` | пройден |
| `GVL_TestsStation.fbAnnunciatorTest` | `Annunciator_LampSteadyWhenActiveAcked_A14_PMI36` | пройден |
| `GVL_TestsStation.fbAnnunciatorTest` | `Annunciator_K1DeenergizedOnActiveHigh_A14_PMI17` | пройден |
| `GVL_TestsStation.fbAnnunciatorTest` | `Annunciator_TimeBackwardsRestartsBlink_A14` | пройден |
| `GVL_TestsStation.fbStationCfgCheckTest` | `StationCfgCheck_DefaultsPass_A18` | пройден |
| `GVL_TestsStation.fbStationCfgCheckTest` | `StationCfgCheck_LevelOrderBit_A18_PMI08` | пройден |
| `GVL_TestsStation.fbStationCfgCheckTest` | `StationCfgCheck_LevelRangeBit_A18_PMI08` | пройден |
| `GVL_TestsStation.fbStationCfgCheckTest` | `StationCfgCheck_SpeedBit_A18` | пройден |
| `GVL_TestsStation.fbStationCfgCheckTest` | `StationCfgCheck_PidStagingBit_A18` | пройден |
| `GVL_TestsStation.fbStationCfgCheckTest` | `StationCfgCheck_DutyBit_A18` | пройден |
| `GVL_TestsStation.fbStationCfgCheckTest` | `StationCfgCheck_RotationBit_A18` | пройден |
| `GVL_TestsStation.fbStationCfgCheckTest` | `StationCfgCheck_TimesBit_A18` | пройден |
| `GVL_TestsStation.fbStationCfgCheckTest` | `StationCfgCheck_FloatCheckBit_A18` | пройден |
| `GVL_TestsStation.fbStationCfgCheckTest` | `StationCfgCheck_UnderloadBit_A18` | пройден |
| `GVL_TestsStation.fbStationCfgCheckTest` | `StationCfgCheck_AlarmBit_A18` | пройден |
| `GVL_TestsStation.fbStationCfgCheckTest` | `StationCfgCheck_SetpointBit_A18_PMI08` | пройден |
| `GVL_TestsStation.fbStationCfgCheckTest` | `StationCfgCheck_NanRejected_A18` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_StationStsSizeIs72_A19` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_StationDefaultsMatchTypeDefaults_A18` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_PlcStartLogsEventAndDelaysRequests_A13_PMI01_PMI35` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_ManualDryRunInterlocksAllPumps_A10_PMI18` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_CommandPulsesClearedAndCounted_A19_PMI30_PMI36` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_ResetButtonEdgeResetsAndLogs_A14_PMI36` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_LkgRejectsInvalidCfg_A18_PMI08` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_RevertCfgRestoresLkg_A18_PMI08` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_LkgRestoredAfterRestart_A18_PMI35` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_RestoredInvalidLkgFallsBackToDefaults_A18` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_ApplyProjectCfgRestoresDefaults_A18` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_EmergencyRequiresAllAtFullSpeed_A10_PMI20` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_PowerLostSuppressesLackNoresAts_A13_A15_PMI33` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_LackSuppressesNoReserve_A9_A15_PMI17` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_StepFallbackSuppressedInEmergency_A7_A15_PMI28` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_PidControlsLeadSpeed_A7_PMI04` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_FloatModeStartsAllOnLs102_A11_PMI21_PMI25` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_AtsReplacesFaultedLead_A9_PMI12_PMI13` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_UnderloadTripInterlocksAndAts_A10_PMI15` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_ManualToAutoAdoptsRunningPump_A3_PMI30` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_ExportCommandAndEvents_A16_PMI37` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_AlarmIdCommandsResultAndClear_A15_PMI36` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_SimulationAlarmAndFaultEvent_A15_A16_PMI01` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_FlowAlarmsSuppressedUntilSettled_A15_PMI38` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_VentilationAndAnnunciatorOutputs_A14_A17_PMI36_PMI38` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_DryRunStopSuppressesNoReserve_A10_A11_A15_PMI21` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_StepAlarmNoFlickerOnStartAndAutoEntry_A3_A7_A15_PMI01_PMI30` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_OverheatTripIsAts_A9_A10_PMI16` | пройден |
| `GVL_TestsStation.fbStationCoreTest` | `StationCore_RestartSequencesEmergencyPumps_A10_A13_PMI34` | пройден |

### Упавшие тесты

_Нет._

Машиночитаемые результаты: `build/test-results.json`, `build/junit.xml` (не в git).
<!-- cds:test-report:end -->

## Сборка контура в CODESYS (объединённый проект)

CODESYS 3.5.17.30, профиль `CODESYS V3.5 SP17 Patch 3`, CODESYS Control Win V3 (пользовательский процесс),
локально, 19.10.2026 — ветка `main` после слияния веток команд (`feat/io`, затем `feat/model`) и
интеграционных правок (DESIGN 0.4, ASSUMPTIONS И1–И11). Проекты созданы заново (`cds.py import --clean`,
`cds.py import --tests --clean`): объект Persistent Variables `GVL_Persist` создаёт сам импорт (И7).

| Команда | Итог | Примечание |
|---|---|---|
| `cds.py deps --check` | все есть | plc-process-lib 1.0.0.0, CAA File 3.5.17.0, SysTimeRtc 3.5.17.0, coUnit 1.2.0.0, Standard 3.5.17.0 |
| `cds.py check` | 0 ошибок, 0 предупреждений | 85 объектов `src/` |
| `cds.py check --tests` | 0 ошибок, 0 предупреждений | 121 объект `src/` и `tests/` |
| `cds.py build` | 0 ошибок, 0 предупреждений | `MainTask` (`PRG_FieldIn`, `PRG_DeviceList`, `PRG_Station`, `PRG_Devices`, `PRG_FieldOut`), `PlantModelTask` (`PRG_PlantModel`), `SlowTask` (`PRG_Slow`) |
| `cds.py build --tests` | 0 ошибок, 0 предупреждений | — |
| `cds.py test` | 324 из 324 | 29 наборов: станция — 184, слой К3 и подхват насоса — 58, модель и часы — 82 (раздел выше) |
| `cds.py roundtrip` | экспорт совпал побайтно (1003 файла), повторный импорт — 0 изменений | с объектом `GVL_Persist` |
| `symbol_config.py` (сборки `sim` и `site`) | файл символов совпал с правилами | `sim`: `GVL_Persist` 1 Read (`stStationCfgLkg`) и 37 ReadWrite, `GVL_Sim` 4 Read (с `xIoReady`) и 3 ReadWrite, `GVL_Station` 7 Read и 2 ReadWrite; `site`: `GVL_Persist` 38 Read, `GVL_Sim` 4 Read |

Новые тесты сборки контура: `StationCore_LkgRestoredAfterRestart_A18_PMI35`,
`StationCore_RestoredInvalidLkgFallsBackToDefaults_A18` (написаны до исправления: на ядре без
восстановления копии LKG прогон дал 324 теста, 2 упали — эти два), `PlcStartAdoption_AdoptedInGeneratedOrder_A13`,
`PlcStartAdoption_PowerDeviceAfterPumpStopsRunningPump_A13`.

### Ветка К3 до слияния (история)

CODESYS 3.5.17.30, профиль `CODESYS V3.5 SP17 Patch 3`, локально, 19.10.2026 — ветка команды К3
(сгенерированный слой, полевой слой, журнал). Объекты логики станции и модели (К1, К2), на которые
ссылаются задачи и сгенерированный слой (`PRG_Station`, `PRG_PlantModel`, `GVL_Time`, `GVL_Sim`, типы станции
и имитации), подставлены копиями из веток команд (в коммиты К3 не входят): итог для объединённого проекта —
после слияния.

| Команда | Итог | Примечание |
|---|---|---|
| `cds.py deps --check` | все есть | plc-process-lib 1.0.0.0, CAA File 3.5.17.0, SysTimeRtc 3.5.17.0, coUnit 1.2.0.0, Standard |
| `cds.py check` | 0 ошибок, 0 предупреждений | 58 объектов `src/` (с копиями объектов К1, К2) |
| `cds.py check --tests` | 0 ошибок, 0 предупреждений | 68 объектов `src/` и `tests/` |
| `cds.py build` | 0 ошибок, 0 предупреждений | MainTask, PlantModelTask, SlowTask; Persistent Variables — `codesys_pvl.py` (MANUAL_STEPS 9.3) |
| `cds.py build --tests` | 0 ошибок, 0 предупреждений | — |
| `cds.py test` | 56 из 56 | раздел выше; мутационное тестирование — раздел ниже |
| `symbol_config.py` (сборки `sim` и `site`) | файл символов совпал с правилами | `sim`: `GVL_Devices` 29 Read, `GVL_Hmi` 30 ReadWrite, `GVL_IO` 86 Read, `GVL_Log` 4 Read + 2 ReadWrite, `GVL_Persist` 37 ReadWrite, `GVL_Sim` 3 + 3, `GVL_Time` 1; поля типов: `ST_EventView` — запись только `uiPage`, `ST_EventFeed` — только `udiFromSeq`, `ST_EventRecord` — только чтение; `site`: `GVL_Persist` 37 Read, `GVL_Sim` 3 Read; повтор — 0 изменений |
| `cds.py roundtrip` | не запускался | в чистом проекте не было объекта Persistent Variables; после сборки контура его создаёт импорт — `roundtrip` проходит (выше) |


## Прогон приложения имитации на Control Win (сборка контура)

Приложение рабочего режима (имитация) загружено в Control Win V3 и запущено вспомогательным онлайн-скриптом
CODESYS (не в репозитории: вход и загрузка — как у `cds.py test`, чтение — `read_values`, запись —
подготовленные значения, сброс — `ScriptOnlineApplication.reset`). Записи журнала читались курсором
`GVL_Log.stEventFeed`, тревоги — списком `GVL_Log.stAlarmView`. Станция — в «Ручном» (пустой retain).

| Проверка | До исправления | После |
|---|---|---|
| Старт имитации: журнал и тревоги за первые 12 с | тревоги ES301 (3010), LS102 (1020), LS103 (1030), TS112, TS122, TS132 (1120, 1220, 1320) — ActiveUnack, затем RtnUnack; события 101008 «нет напряжения», 101013 «переход на поплавки», `KNS1.FLOAT` (100006) ActiveUnack; 101018 по каждому AI и DI | 101015 «старт», 101009 «последовательный пуск», `KNS1.SIM` (100013) ActiveUnack, подавленные по условию `KNS1.LACK`, `KNS1.NORES` и пределы PT201, FT202 (насосы не работают); ложных тревог и событий нет (ASSUMPTIONS И2, И4) |
| `GVL_Sim.xIoReady` | — | TRUE с первого чтения (0,2 с после «Старт») |
| Уставки: правка задания 1,8 м, затем 2,5 м (вне 1,2…2,2 LIC101) | — | 1,8 м принята (`stCfgLkg` и `GVL_Persist.stStationCfgLkg` = 1,8, событие 101017), 2,5 м отклонена (`wCfgErr = 16#0400`, копия 1,8) |
| Тёплый сброс и «Старт» с неверной правкой в `GVL_Persist.stStationCfg` | — | действующая копия 1,8 м (сохранённая), а не 1,4 м уставок проекта; `wCfgErr = 16#0400`; журнал после сброса — те же 13 записей старта (ASSUMPTIONS И6, И11) |

Перезапуск процесса рантайма и загрузка изменённой программы с сохранением энергонезависимых данных
(PMI-35) не проверялись: это сценарий ПМИ с ручным шагом (R-02 архитектуры).

## Мутационное тестирование слоя К3 (19.10.2026)

Мутационная проверка логики станции — ASSUMPTIONS S21, S29 (26 мутаций, все убиты после усиления
тестов); модели — тесты по итогам проверки M14–M18 (ASSUMPTIONS, раздел К2).

Копия рабочей копии с объектами К1 и К2 (вне репозитория), по одному изменению поведения на мутант (у ST —
группами по непересекающимся наборам тестов), `cds.py test` в CODESYS Control Win и `pytest` для Python.
Мутант убит, если упал хотя бы один тест его набора. Выжившие после первого прохода закрыты новыми тестами
(указаны в скобках) и прогнаны повторно.

| Поведение | Мутантов | Убито | Примеры мутантов и тесты, которые их ловят |
|---|---:|---:|---|
| Адаптер ПЧ, `Decode`: связь, биты, масштаб | 6 | 6 | `xCommOk := TRUE`, авария без связи, скорость без связи, бит «готов» от «в работе», масштаб 1/100 — `NoCommForcesStatusFalseHoldsSpeed`, `DecodeBits`, `DecodeScale5000Is100Pct` |
| Адаптер ПЧ, `Encode`: бит сброса, масштаб, предел, округление, NaN | 6 | 6 | инверсия и не тот бит сброса, отбрасывание дробной части (`EncodeRoundsToNearest`), без предела 100 %, NaN держит задание — `EncodeResetBitWhileQReset`, `EncodeScaleAndClamp`, `EncodeNanIsZero` |
| Журнал: кольцо, затирание, номера, время | 5 | 5 | затирание не считается, кольцо короче на запись, время мимо `itfTime`, пропуск номеров, `GetRecord` со сдвигом — `RingOverwritesOldestAndCounts`, `MonoTimeIsProcessTime` и др. |
| Журнал: курсор и страницы | 5 | 5 | курсор без ограничения самой старой записью, первая запись со сдвигом, неочищенные строки, счётчик строк, ограничение номера страницы (`ViewPageEqualToCountClamped`) |
| Журнал: снимок | 3 | 3 | порядок кольца без перестановки (`SnapshotAfterWrapOldestFirst`), «новые первыми», граница индекса |
| Выгрузка CSV и обмен `PRG_Slow` | 7 | 6 | прежний обмен, снятие запроса только по `Done`, вторая выгрузка не стартует, без заголовка, без счёта строк, потеря кода ошибки открытия — `SlowTaskRequestHandshake`, `ReadBackMatchesSnapshot`, `WritesHeaderAndAllLines`, `ErrorOnBadPathReported`. Выжил: «успех после ошибки записи» — ветка ошибки `FILE.Write`/`FILE.Close`, её на Control Win не вызвать без внедрения отказа в CAA File (закрыта ревью кода) |
| `F_UtcToIso` | 5 | 5 | февраль без переноса года, сдвиг эпохи, миллисекунды без двух нулей, правило 400 лет (`CenturyLeapDay2000`), 0 → не пусто |
| `F_AlarmCode` | 4 | 4 | таблица задвижки для двигателя, номер события со сдвигом, первая тревога станции, слот без суффикса (`SlotWithoutSuffixIsNumber`) |
| `FB_AlarmSummary` | 7 | 7 | RtnUnack как активная, приоритет последней вместо высшей (`PrioUnackHighestBeforeLower`), новые High каждый цикл, квитированные в группе неквитированных, без «новые выше» (`ViewNewerFirstInGroup`), пересчёт каждый цикл, свой срок откладывания (`ShelveByIdUsesFullTShelveMax`) |
| Обвязка сценариев (Python) | 12 | 11 | граница поиска по номеру журнала, допуск `max_s`/`min_s`, единицы TIME/LTIME, перезапуск журнала, пропуск одной записи, ошибки шага в отчёте, переполнение списка тревог, импульс без ожидания сброса — `scenarios/test_harness_robustness.py`, `test_harness.py`. Выжил: курсор принимает строки «номер ≥ ожидаемого» вместо «=» — эквивалентен: `FillFeed` отдаёт строки подряд с `MAX(udiFromSeq, первая)`, а пропуск ловится раньше |
| Символьная конфигурация (Python) | 6 | 6 | последнее правило вместо первого, регистр имён, поля всегда ReadWrite, без сверки полей, доступ без учёта сборки, переменная без правила не замечена — `test_symbol_config.py`, `test_scenario_files.py` |
| **Всего** | **66** | **64** | |

## Что проверяют тесты

| Набор | Тестов | Что проверяет |
|---|---:|---|
| `FB_VfdAdapter_Cond_Test` | 8 | биты слова состояния, масштаб 5000 = 100 %, без связи статусы FALSE и последняя скорость, бит сброса, задание с ограничением и округлением до ближайшего отсчёта, NaN и +Inf → 0, умолчания |
| `FB_EventLog_Test` | 14 | запись тревоги и события станции (101000 + код), кольцо на 200 и счётчик затёртых, «новые первыми», страницы HMI (в том числе номер, равный числу страниц), курсор и пропуск затёртых, время процесса, «время назад», снимок (в том числе после затирания кольца), размер записи 40 байт, пустой журнал |
| `FB_EventLogCsv_Test` | 6 | формат строки CSV; в рантайме через CAA File: заголовок и 25 строк, пустой снимок, чтение файла назад побайтно, ошибка открытия, обмен `PRG_Slow` ↔ MainTask (запрос снят при старте, вторая выгрузка сразу после `Done`) |
| `FB_F_UtcToIso_Test` | 4 | ISO 8601 по эталонам Python (29.02.2024, 2100 год, 29.02.2000 — граница 400-летнего цикла), 0 → пусто, ведущие нули |
| `FB_F_AlarmCode_Test` | 5 | коды устройств по типу и слоту (слот без суффикса — номер слота), тревоги станции, LIC101.PVF, KNS1.E<код>, неизвестные номера |
| `FB_AlarmSummary_Test` | 15 | счётчики по приоритетам, высший неквитированный (независимо от порядка обхода), новые High/Critical, порядок списка (группа, приоритет, новые выше) и его предел, период и «время назад», квитирование и откладывание по номеру с `tShelveMax` (весь срок тревоги), соответствие `ALM_SLOT_MAX` библиотеке |
| `FB_DeviceAudit_Test` | 4 | событие 101018 со значением dev_no · 10 + режим (dev_no 9999 — без переполнения), без события при старте и без журнала |
| `FB_PlcStartAdoption_Test` | 2 | подхват работающего насоса при старте ПЛК настоящими `PL.FB_DigitalInput` и `PL.FB_MotorVfd` с параметрами проекта: в порядке `PRG_Devices` (ES301 раньше P101) — Running с командой, пуск не засчитан, 5 с без отказов; в обратном порядке — останов «нет напряжения» |
| `FB_StationCore_Test` | 29 | порядок цикла станции с подменными насосами: старт ПЛК, команды и кнопки, уставки LKG (в том числе восстановление энергонезависимой копии после перезапуска и замена неверной копии уставками проекта), действующее управление и требуемое число, подавления тревог, NE 107, `wState`, LIC101, АВР, «Ручной» → «Автомат», журнал, В1 и сигнализация |
| ФБ станции: `FB_StationMode_Test` (10), `FB_ControlSelector_Test` (5), `FB_LevelControlStepped_Test` (11), `FB_LevelControlPid_Test` (15), `FB_PumpRotation_Test` (28), `FB_Ats_Test` (13), `FB_Protections_Test` (21), `FB_PumpProtection_Test` (9), `FB_PowerRestore_Test` (10), `FB_Ventilation_Test` (4), `FB_StationAlarms_Test` (9), `FB_Annunciator_Test` (7), `FB_F_StationCfgCheck_Test` (13) | 155 | алгоритмы 04: режимы и способ, старшинство управления, ступенчатое и ПИД с подпорным, роли и чередование, АВР, защиты и поплавки, недогрузка и перегрев, последовательный пуск, вентиляция, тревоги KNS1.*, сигнализация, проверка уставок; у каждого ФБ — умолчания, границы, «время назад» |
| Модель: `FB_ScaledClock_Test` (8), `FB_InflowProfile_Test` (6), `FB_StormGenerator_Test` (10), `FB_TankModel_Test` (8), `FB_HydraulicSolver_Test` (11), `FB_VfdSim_Test` (15), `FB_PlantModel_Test` (24) | 82 | часы с ускорением, приток и ливни по seed, баланс резервуара и перелив, рабочая точка насосов и токи против эталона `plant_reference.py`, модель ПЧ (рампа, авария, сторожевой таймер 5 с → 50 Гц), модель целиком (инъекции, команды, согласованность при разном шаге) |

## Проверки без CODESYS

| Проверка | Итог | Примечание |
|---|---|---|
| `ruff check`, `ruff format --check`, `mypy` (strict) | пройдено, 19.10.2026, локально | `tools/`, `tools_project/`, `scenarios/` (48 модулей mypy) |
| `pytest` (с `PL_REPO` и `IOLISTGEN_REPO`) | 710 пройдено, 4 пропущено (19.10.2026) | тесты инструментов шаблона, сверка генерации побайтно и порядок вызова устройств, перекрытие шаблона `PRG_Devices` против шаблона пакета iolistgen, разметка PLCopenXML объекта Persistent Variables, правила символов, обвязка сценариев на имитаторе OPC UA-сервера, сверка документов; снимок plc-process-lib и вывод iolistgen сверены с исходниками; пропущены — сценарии на рантайме (`PMI_LIVE=1`) и каталог 39 сценариев (ещё нет) |
| `tools_project/generate.py --check` | дрейфа нет (20 файлов) | iolistgen 0.2.0 |
| `tools_project/check_docs_consistency.py` | 20 проверок, 0 расхождений | — |
| `tools/assemble.py --tests` | 121 объект | все варианты сборки |
| `st_lint --strict`, iec_checker 0.4, RuSTy 1.0.6 | 0 ошибок, необоснованных находок 0 | [STATIC_ANALYSIS.md](STATIC_ANALYSIS.md): `st_lint` — 1003 файла; iec_checker — 121 объект, обоснованных 4297; RuSTy — 35 файлов, исключено 87 |
