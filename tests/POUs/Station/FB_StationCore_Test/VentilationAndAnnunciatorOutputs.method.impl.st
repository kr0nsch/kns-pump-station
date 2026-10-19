coUnit.TEST('StationCore_VentilationAndAnnunciatorOutputs_A14_A17_PMI36_PMI38');

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
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
      xPlant := TRUE);

fbDut.xGasHigh := TRUE;
fbDut.auiUnack[3] := 1;
fbDut.auiActive[3] := 1;
fbDut.ePrioUnack := PL.E_AlarmPriority.High;
fbDut.udiNewHighSeq := 1;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.xV1Run, Message := 'gas: V1 runs');
AssertTrue(Condition := fbDut.xHorn AND NOT fbDut.xK1, Message := 'horn on, K1 de-energized');
AssertTrue(Condition := (fbDut.stSts.wState AND (GVL_Const.STN_ST_HORN OR GVL_Const.STN_ST_COMMON_ALARM
                         OR GVL_Const.STN_ST_UNACK)) = (GVL_Const.STN_ST_HORN OR GVL_Const.STN_ST_COMMON_ALARM
                         OR GVL_Const.STN_ST_UNACK), Message := 'wState horn, common alarm, unacked');
fbDut.xFire := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
      xPlant := TRUE);

AssertFalse(Condition := fbDut.xV1Run, Message := 'fire: V1 stopped');
AssertEquals_WORD(Expected := GVL_Const.V1_ILK_FIRE, Actual := fbDut.wV1Interlock, Message := 'fire interlock');

coUnit.TEST_FINISHED();
