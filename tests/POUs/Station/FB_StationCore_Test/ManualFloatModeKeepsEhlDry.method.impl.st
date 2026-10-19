coUnit.TEST('StationCore_ManualFloatModeKeepsEhlDry_A3_A10_A11_A15');

stPidCfg := GVL_StationDefaults.stLIC101Cfg;
stRetain.eMode := E_StationMode.Manual;
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

// отказ LT101, затем LS102
fbDut.xLevelValid := FALSE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 10,
      xPlant := TRUE);
fbDut.xFloatHigh := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 10,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.Manual, Message := 'Manual: no float control');
AssertFalse(Condition := fbDut.axRun[1] OR fbDut.axRun[2] OR fbDut.axRun[3], Message := 'Manual: no pump requested');
itfEhl := fbAlarms.GetAlarm(uiIndex := E_StationAlarm.EHL - 1);
AssertTrue(Condition := itfEhl.State = PL.E_AlarmState.ActiveUnack, Message := 'Manual: KNS1.EHL not suppressed');
// LS102 снят, LS103: сухой ход блокирует насосы и в «Ручном»
fbDut.xFloatHigh := FALSE;
fbDut.xFloatDry := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 10,
      xPlant := TRUE);

AssertTrue(Condition := (fbDut.awInterlock[1] AND GVL_Const.KNS_ILK_DRY_RUN) <> 0, Message := 'dry run interlock');
itfDry := fbAlarms.GetAlarm(uiIndex := E_StationAlarm.DRY - 1);
AssertTrue(Condition := itfDry.State = PL.E_AlarmState.ActiveUnack, Message := 'Manual: KNS1.DRY not suppressed');
// «Автомат»: управление по поплавкам действует — сухой ход по LS103 штатен, DRY подавлена
stCmd.xSetAuto := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 10,
      xPlant := TRUE);

AssertTrue(Condition := itfDry.State = PL.E_AlarmState.SuppressedByDesign,
           Message := 'Auto float mode: DRY suppressed');

coUnit.TEST_FINISHED();
