# Отчёт о тестировании

Результаты юнит-тестов CfUnit (coUnit 1.2.0.0) в CODESYS Control Win V3 и проверок без CODESYS.
Запись «проверено в CODESYS» появляется только после реального прогона. Раздел «Последний прогон
в CODESYS» обновляет `python tools/codesys/cds.py report` по итогам `cds.py test`
(`build/test-results.json`); правки внутри него вручную перезаписываются.

<!-- cds:test-report:begin (раздел обновляет `python tools/codesys/cds.py report`) -->
## Последний прогон в CODESYS

Проверено в CODESYS 3.5.17.30 / CODESYS Control Win V3 (пользовательский процесс) — 2026-10-19 16:09:30. Итог: **все тесты пройдены**.

| Параметр | Значение |
|---|---|
| Дата прогона | 2026-10-19 16:09:30 |
| Коммит | faf1ef2 |
| CODESYS | 3.5.17.30 (профиль `CODESYS V3.5 SP17 Patch 3`) |
| Устройство в проекте | CODESYS Control Win V3 (4096 / 0000 0001 / 3.5.17.30) |
| Рантайм | CODESYS Control Win V3 (пользовательский процесс) |
| Фреймворк тестов | coUnit (CfUnit) 1.2.0.0 |
| Сборка | ошибок 0, предупреждений 0 |
| Способ запуска | `python tools/codesys/cds.py test` |

| Набор | Тестов | Пройдено | Упало | Пропущено | Итог |
|---|---|---|---|---|---|
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
| `GVL_TestsStation.fbStationCoreTest` | 27 | 27 | 0 | 0 | пройдено |
| `PRG_Tests.fbF_ClampTest` | 7 | 7 | 0 | 0 | пройдено |
| `PRG_Tests.fbExampleTest` | 11 | 11 | 0 | 0 | пройдено |
| **Всего** | 200 | 200 | 0 | 0 | **пройдено** |

### Результаты тестов

| Набор | Тест | Итог |
|---|---|---|
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
| `PRG_Tests.fbF_ClampTest` | `InsideRangeReturnsValue` | пройден |
| `PRG_Tests.fbF_ClampTest` | `BelowLowReturnsLow` | пройден |
| `PRG_Tests.fbF_ClampTest` | `AboveHighReturnsHigh` | пройден |
| `PRG_Tests.fbF_ClampTest` | `AtLowBoundaryReturnsLow` | пройден |
| `PRG_Tests.fbF_ClampTest` | `AtHighBoundaryReturnsHigh` | пройден |
| `PRG_Tests.fbF_ClampTest` | `EqualBoundsReturnsBound` | пройден |
| `PRG_Tests.fbF_ClampTest` | `LowGreaterThanHighSwapsBounds` | пройден |
| `PRG_Tests.fbExampleTest` | `AutoSwitchesOnBelowThreshold` | пройден |
| `PRG_Tests.fbExampleTest` | `AutoThresholdsAreInclusive` | пройден |
| `PRG_Tests.fbExampleTest` | `AutoHoldsStateInsideHysteresis` | пройден |
| `PRG_Tests.fbExampleTest` | `InvalidValueLatchesFault` | пройден |
| `PRG_Tests.fbExampleTest` | `AcknowledgeClearsFaultWhenValid` | пройден |
| `PRG_Tests.fbExampleTest` | `AcknowledgeKeepsFaultWhileInvalid` | пройден |
| `PRG_Tests.fbExampleTest` | `ManualFollowsCommand` | пройден |
| `PRG_Tests.fbExampleTest` | `LocalAndOutOfServiceSwitchOff` | пройден |
| `PRG_Tests.fbExampleTest` | `DefaultModeIsOutOfService` | пройден |
| `PRG_Tests.fbExampleTest` | `ParametersAreClamped` | пройден |
| `PRG_Tests.fbExampleTest` | `CountsSwitchOnsAndResetClears` | пройден |

### Упавшие тесты

_Нет._

Машиночитаемые результаты: `build/test-results.json`, `build/junit.xml` (не в git).
<!-- cds:test-report:end -->

## Сборка и полная проверка компиляции в CODESYS

CODESYS 3.5.17.30, профиль `CODESYS V3.5 SP17 Patch 3`, локально, 2026-10-16. `build` компилирует
объекты, достижимые из задач; `check` — все объекты раскладки (docs/MANUAL_STEPS.md, раздел 5).

| Команда | Итог | Примечание |
|---|---|---|
| `cds.py build` | 0 ошибок, 0 предупреждений | ссылки проекта: `#Standard` из `config.json` и плейсхолдеры устройства (`#IoStandard`, `#3SLicense`, `#CAA Device Diagnosis`, `#BreakpointLogging`); повторный импорт — 0 изменений |
| `cds.py check` | 0 ошибок, 0 предупреждений | 8 объектов `src/` (включая `PRG_Main`) |
| `cds.py check --tests` | 0 ошибок, 0 предупреждений | 11 объектов `src/` и `tests/` |
| `cds.py test` | 18 из 18 | раздел выше |
| `cds.py roundtrip` | без диффа (60 файлов), повторный импорт — 0 изменений | — |
| `cds.py library` | 0 ошибок проверки пула | 7 объектов, ссылка библиотеки — `#Standard` |

Проверка самой команды `check` на копии шаблона (вне репозитория): программа без задачи с
`iX := diZ;`, ФБ без экземпляра с ошибкой в методе, неиспользуемый DUT, вспомогательный ФБ в
`tests/` с ошибкой — `build` «0 ошибок» (код 0), `check` / `check --tests` — каждая ошибка с файлом
и строкой раскладки (код 1); после удаления — код 0. GVL с типами библиотек устройства
(`IoStandard.IoConfigConnector`, `DED.DEVICE_STATE`): `build` и `check` — 0 ошибок (ссылки
устройства копируются в пул проверки). Standard в той же копии (TON, R_TRIG, CTU, CONCAT без
пространства имён и с `Standard.`): `build`, `check --tests`, `library` — 0 ошибок, `test` — 19 из
19; без ссылки `standard` — C0077 «Неизвестный тип: 'TON'» (docs/ASSUMPTIONS.md, D37–D39).

## Что проверяют тесты

| Набор | Тест | Что проверяет |
|---|---|---|
| `FB_F_Clamp_Test` | `InsideRangeReturnsValue` | значение внутри диапазона не меняется |
| `FB_F_Clamp_Test` | `BelowLowReturnsLow` | значение ниже диапазона → нижняя граница |
| `FB_F_Clamp_Test` | `AboveHighReturnsHigh` | значение выше диапазона → верхняя граница |
| `FB_F_Clamp_Test` | `AtLowBoundaryReturnsLow` | значение на нижней границе не меняется |
| `FB_F_Clamp_Test` | `AtHighBoundaryReturnsHigh` | значение на верхней границе не меняется |
| `FB_F_Clamp_Test` | `EqualBoundsReturnsBound` | вырожденный диапазон `rLow = rHigh` |
| `FB_F_Clamp_Test` | `LowGreaterThanHighSwapsBounds` | `rLow > rHigh`: границы меняются местами |
| `FB_Example_Test` | `AutoSwitchesOnBelowThreshold` | авторежим: значение ниже порога включения (уставка − гистерезис) включает выход, отказа нет |
| `FB_Example_Test` | `AutoThresholdsAreInclusive` | авторежим: на пороге включения выход включается, на уставке — отключается |
| `FB_Example_Test` | `AutoHoldsStateInsideHysteresis` | авторежим: в зоне гистерезиса выход сохраняет состояние (после включения и после отключения) |
| `FB_Example_Test` | `InvalidValueLatchesFault` | недостоверное измерение в авторежиме: отказ, выход отключён; отказ держится после восстановления измерения |
| `FB_Example_Test` | `AcknowledgeClearsFaultWhenValid` | `Acknowledge()` при достоверном измерении снимает отказ и возвращает TRUE, выход снова управляется |
| `FB_Example_Test` | `AcknowledgeKeepsFaultWhileInvalid` | `Acknowledge()` при недостоверном измерении возвращает FALSE, отказ остаётся |
| `FB_Example_Test` | `ManualFollowsCommand` | ручной режим: выход повторяет `xManualOn`, недостоверное измерение отказа не даёт |
| `FB_Example_Test` | `LocalAndOutOfServiceSwitchOff` | `Local` и `OutOfService` отключают выход при любых измерении и команде |
| `FB_Example_Test` | `DefaultModeIsOutOfService` | режим по умолчанию — `OutOfService`: выход отключён |
| `FB_Example_Test` | `ParametersAreClamped` | уставка и гистерезис вне диапазона ограничиваются `EXAMPLE_SP_MAX_PCT` и `EXAMPLE_HYST_MIN_PCT` |
| `FB_Example_Test` | `CountsSwitchOnsAndResetClears` | счётчик `Count` считает только фронты включения; `Reset()` через `I_Resettable` отключает выход и обнуляет счётчик |

## Проверки без CODESYS

Итоги последнего прогона CI (ссылка на запуск GitHub Actions) или локального прогона.

| Проверка | Итог | Примечание |
|---|---|---|
| `ruff check`, `ruff format --check`, `mypy`, `pytest` | пройдено, 2026-10-16, локально | pytest: все тесты, включая интеграционные с настоящими `plc` и iec_checker |
| `tools/assemble.py` (все варианты, с `--tests` и без) | пройдено, 2026-10-16, локально | 8 объектов `src/` + 3 объекта `tests/` |
| `tools/check/st_lint.py --strict` | пройдено, 2026-10-16, локально | 60 файлов, 0 замечаний |
| iec_checker 0.4 (локально, `run_iec_checker.py --tests`) | пройдено, 2026-10-16 | 11 файлов, ошибок разбора нет; необоснованных находок 0, обоснованных 100 — разбор в [STATIC_ANALYSIS.md](STATIC_ANALYSIS.md) |
| RuSTy 1.0.6 (локально, `run_rusty.py`) | пройдено, 2026-10-16 | 11 файлов (`src/` и `tests/` с прокладкой coUnit), исключений нет, 0 ошибок, 0 предупреждений |
