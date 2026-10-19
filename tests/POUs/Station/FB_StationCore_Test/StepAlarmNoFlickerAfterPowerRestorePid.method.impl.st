coUnit.TEST('StationCore_StepAlarmNoFlickerAfterPowerRestorePid_A7_A12_A13_A15_PMI33_PMI34');

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

AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.LevelPid, Message := 'LevelPid before power loss');
// нет напряжения: со следующего цикла насосы недоступны и без связи (ПЧ без питания)
fbDut.xPowerOk := FALSE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
      xPlant := TRUE);
FOR uiIdx := 1 TO 3 DO
    afbPump[uiIdx].xAvailable := FALSE;
    fbDut.axCommOk[uiIdx] := FALSE;
END_FOR
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 300,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.PowerLost, Message := 'PowerLost');
itfStep := fbAlarms.GetAlarm(uiIndex := E_StationAlarm.STEP - 1);
AssertTrue(Condition := itfStep.State = PL.E_AlarmState.SuppressedByDesign, Message := 'PowerLost: STEP suppressed');
// напряжение восстановлено (ES301 подтвердил): насосы доступны циклом позже, ПЧ ещё 2 с загружаются
fbDut.xPowerOk := TRUE;
xFlicker := FALSE;
FOR uiStep := 1 TO 300 DO
    Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
          stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
          stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
          xPlant := TRUE);
    xFlicker := xFlicker OR (fbDut.stSts.wAlmUnack AND 16#0080) <> 0;
    IF uiStep = 1 THEN
        FOR uiIdx := 1 TO 3 DO
            afbPump[uiIdx].xAvailable := TRUE;
        END_FOR
    ELSIF uiStep = 21 THEN
        AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.Restart, Message := 'sequential start');
        FOR uiIdx := 1 TO 3 DO
            fbDut.axCommOk[uiIdx] := TRUE;
        END_FOR
    END_IF
END_FOR

AssertFalse(Condition := xFlicker, Message := 'no unacked KNS1.STEP after power restore');
AssertTrue(Condition := itfStep.State = PL.E_AlarmState.Normal, Message := 'STEP normal');
AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.LevelPid, Message := 'LevelPid 30 s after restore');
AssertEquals_WORD(Expected := 0, Actual := fbDut.stSts.wState AND GVL_Const.STN_ST_STEP_FALLBACK,
                  Message := 'wState: no step fallback bit');

coUnit.TEST_FINISHED();
