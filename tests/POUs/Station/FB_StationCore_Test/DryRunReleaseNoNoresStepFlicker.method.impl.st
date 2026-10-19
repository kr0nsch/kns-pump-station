coUnit.TEST('StationCore_DryRunReleaseNoNoresStepFlicker_A7_A10_A15_PMI22');

stPidCfg := GVL_StationDefaults.stLIC101Cfg;
stRetain.eMode := E_StationMode.Auto;
stRetain.eMethod := E_ControlMethod.LevelPid;
stPidRetain.eRemoteMode := PL.E_DeviceMode.Auto;
fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.axCommOk[1] := TRUE;
fbDut.axCommOk[2] := TRUE;
fbDut.axCommOk[3] := TRUE;
fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.2;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut.rLvlL_m := 0.8;
fbDut.rLvlH_m := 3.5;
fbDut.xPowerOk := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 110,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.LevelPid, Message := 'LevelPid before dry run');
// LL по уровнемеру: сухой ход 20 с; насос недоступен с цикла после блокировки (как устройство после станции)
fbDut.rLevel_m := 0.45;
fbDut.xLevelL := TRUE;
fbDut.xLevelLL := TRUE;
FOR uiStep := 1 TO 200 DO
    Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
          stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
          stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
          xPlant := TRUE);
    FOR uiIdx := 1 TO 3 DO
        afbPump[uiIdx].xAvailable := fbDut.awInterlock[uiIdx] = 0;
    END_FOR
END_FOR

AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.DryRunStop, Message := 'DryRunStop');
itfNores := fbAlarms.GetAlarm(uiIndex := E_StationAlarm.NORES - 1);
itfStep := fbAlarms.GetAlarm(uiIndex := E_StationAlarm.STEP - 1);
AssertTrue(Condition := itfNores.State = PL.E_AlarmState.SuppressedByDesign, Message := 'dry run: NORES suppressed');
AssertTrue(Condition := itfStep.State = PL.E_AlarmState.SuppressedByDesign, Message := 'dry run: STEP suppressed');
// уровень выше L: сухой ход снят
fbDut.rLevel_m := 1.0;
fbDut.xLevelL := FALSE;
fbDut.xLevelLL := FALSE;
xFlicker := FALSE;
FOR uiStep := 1 TO 150 DO
    Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
          stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
          stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
          xPlant := TRUE);
    IF uiStep = 1 THEN
        AssertEquals_UINT(Expected := 0, Actual := fbDut.stSts.uiPumpsAvailable,
                          Message := 'release cycle: pumps still interlocked');
    END_IF
    xFlicker := xFlicker OR (fbDut.stSts.wAlmUnack AND 16#0088) <> 0;
    FOR uiIdx := 1 TO 3 DO
        afbPump[uiIdx].xAvailable := fbDut.awInterlock[uiIdx] = 0;
    END_FOR
END_FOR

AssertFalse(Condition := xFlicker, Message := 'no unacked KNS1.NORES or KNS1.STEP on dry run release');
AssertTrue(Condition := itfNores.State = PL.E_AlarmState.Normal, Message := 'NORES normal');
AssertTrue(Condition := itfStep.State = PL.E_AlarmState.Normal, Message := 'STEP normal');
AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.LevelPid, Message := 'LevelPid after dry run');

coUnit.TEST_FINISHED();
