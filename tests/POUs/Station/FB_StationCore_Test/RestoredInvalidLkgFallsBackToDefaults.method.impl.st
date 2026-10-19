coUnit.TEST('StationCore_RestoredInvalidLkgFallsBackToDefaults_A18');

stPidCfg := GVL_StationDefaults.stLIC101Cfg;
stRetain.eMode := E_StationMode.Auto;
stCfgPersist.rLevelSp_m := 2.5;
stCfgLkgRetain.rLevelSp_m := 2.6;
stCfgLkg.rLevelSp_m := 2.6;                           // при старте не важно: копия — из сохранённой или проекта
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
fbTime.Advance(tStep := T#100MS);
fbDut(itfTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stCfgLkgRetain := stCfgLkgRetain, stRetain := stRetain, fbLIC101 := fbPid, stLIC101Cmd := stPidCmd,
      stLIC101Cfg := stPidCfg, stLIC101Retain := stPidRetain, fbAlarms := fbAlarms);

AssertEquals_REAL(Expected := GVL_StationDefaults.stStationCfg.rLevelSp_m, Actual := stCfgLkg.rLevelSp_m,
                  Delta := 0.0, Message := 'invalid retained LKG: project defaults');
stDef := GVL_StationDefaults.stStationCfg;
AssertEquals_UINT(Expected := 0, Actual := fbDut.ChangedParam(stOld := stDef, stNew := stCfgLkgRetain),
                  Message := 'retained LKG replaced by project defaults');
AssertEquals_REAL(Expected := GVL_StationDefaults.stStationCfg.rLevelSp_m, Actual := fbDut.stSts.rLevelSp_m,
                  Delta := 0.0, Message := 'status setpoint from defaults');
AssertEquals_WORD(Expected := GVL_Const.STN_CFG_SETPOINT, Actual := fbDut.stSts.wCfgErr,
                  Message := 'persisted edit still flagged');

coUnit.TEST_FINISHED();
