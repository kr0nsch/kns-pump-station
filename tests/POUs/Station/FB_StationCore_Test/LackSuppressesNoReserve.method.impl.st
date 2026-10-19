coUnit.TEST('StationCore_LackSuppressesNoReserve_A9_A15_PMI17');

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

afbPump[2].eMode := PL.E_DeviceMode.OutOfService;
afbPump[3].eMode := PL.E_DeviceMode.Local;
fbDut.rLevel_m := 2.6;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 250,
      xPlant := TRUE);

AssertEquals_UINT(Expected := 2, Actual := fbDut.stSts.uiPumpsRequired, Message := 'two pumps required');
AssertTrue(Condition := (fbDut.stSts.wAlmActive AND 16#0004) <> 0, Message := 'KNS1.LACK active');
itfAlm := fbAlarms.GetAlarm(uiIndex := E_StationAlarm.NORES - 1);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.SuppressedByDesign, Message := 'NORES suppressed by LACK');
AssertTrue(Condition := fbDut.stSts.eNe107 = PL.E_Ne107Status.Failure, Message := 'NE 107 Failure');
AssertTrue(Condition := (fbDut.stSts.wState AND GVL_Const.STN_ST_LACK) <> 0, Message := 'wState lack bit');

coUnit.TEST_FINISHED();
