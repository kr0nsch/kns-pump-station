coUnit.TEST('StationCore_ManualToAutoStoppedPumpsNoNoresFlicker_A3_A15_PMI30');

stPidCfg := GVL_StationDefaults.stLIC101Cfg;
stRetain.eMode := E_StationMode.Auto;
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

// «Ручной»: насосы выполняют запрос в своём вызове (циклом позже станции)
stCmd.xSetManual := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
      xPlant := TRUE);

FOR uiIdx := 1 TO 3 DO
    afbPump[uiIdx].eMode := afbPump[uiIdx].eLastModeRequest;
END_FOR
AssertTrue(Condition := afbPump[1].eMode = PL.E_DeviceMode.Manual, Message := 'pumps in Manual');
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 150,
      xPlant := TRUE);

itfAlm := fbAlarms.GetAlarm(uiIndex := E_StationAlarm.NORES - 1);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.SuppressedByDesign, Message := 'Manual 15 s: NORES suppressed');
// «Автомат»: в этом цикле насосы ещё в Manual, со следующего — в Auto
stCmd.xSetAuto := TRUE;
xFlicker := FALSE;
FOR uiStep := 1 TO 120 DO
    Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
          stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
          stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
          xPlant := TRUE);
    xFlicker := xFlicker OR (fbDut.stSts.wAlmUnack AND 16#0008) <> 0;
    IF uiStep = 1 THEN
        AssertEquals_UINT(Expected := 0, Actual := fbDut.stSts.uiPumpsAvailable,
                          Message := 'Auto entry cycle: pumps still in Manual');
        FOR uiIdx := 1 TO 3 DO
            afbPump[uiIdx].eMode := afbPump[uiIdx].eLastModeRequest;
        END_FOR
    END_IF
END_FOR

AssertTrue(Condition := fbDut.stSts.eMode = E_StationMode.Auto, Message := 'station in Auto');
AssertEquals_UINT(Expected := 3, Actual := fbDut.stSts.uiPumpsAvailable, Message := 'pumps available in Auto');
AssertFalse(Condition := xFlicker, Message := 'no unacked KNS1.NORES on Auto entry');
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.Normal, Message := 'NORES normal');

coUnit.TEST_FINISHED();
