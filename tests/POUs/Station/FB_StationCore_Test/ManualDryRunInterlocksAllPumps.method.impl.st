coUnit.TEST('StationCore_ManualDryRunInterlocksAllPumps_A10_PMI18');

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

stRetain.eMode := E_StationMode.Manual;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
      xPlant := TRUE);

fbDut.rLevel_m := 0.45;
fbDut.xLevelL := TRUE;
fbDut.xLevelLL := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.Manual, Message := 'Manual');
AssertTrue(Condition := (fbDut.awInterlock[1] AND fbDut.awInterlock[2] AND fbDut.awInterlock[3]
                         AND GVL_Const.KNS_ILK_DRY_RUN) <> 0, Message := 'dry run interlock to all pumps');
AssertFalse(Condition := fbDut.axRun[1] OR fbDut.axRun[2] OR fbDut.axRun[3], Message := 'no requests in Manual');
AssertTrue(Condition := (fbDut.stSts.wAlmActive AND 16#0002) <> 0, Message := 'KNS1.DRY active');
AssertTrue(Condition := (fbDut.stSts.wState AND GVL_Const.STN_ST_DRY_RUN) <> 0, Message := 'wState dry run bit');

coUnit.TEST_FINISHED();
