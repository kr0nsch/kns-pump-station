coUnit.TEST('StationCore_LkgRejectsInvalidCfg_A18_PMI08');

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

stCfgPersist.rLevelSp_m := 1.8;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
      xPlant := TRUE);

AssertEquals_REAL(Expected := 1.8, Actual := stCfgLkg.rLevelSp_m, Delta := 0.0, Message := 'valid setpoint accepted');
AssertEquals_REAL(Expected := 1.8, Actual := fbDut.stSts.rLevelSp_m, Delta := 0.0, Message := 'status setpoint');
AssertEquals_REAL(Expected := 8.0, Actual := fbSink.ValueOf(eFind := E_StationEvent.CfgChanged), Delta := 0.0,
                  Message := 'event 101017 with parameter 8');
stCfgPersist.rLevelSp_m := 2.5;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
      xPlant := TRUE);

AssertEquals_WORD(Expected := GVL_Const.STN_CFG_SETPOINT, Actual := fbDut.stSts.wCfgErr,
                  Message := 'setpoint error bit');
AssertEquals_REAL(Expected := 1.8, Actual := stCfgLkg.rLevelSp_m, Delta := 0.0, Message := 'LKG keeps 1.8');
AssertTrue(Condition := fbDut.stSts.eNe107 = PL.E_Ne107Status.CheckFunction, Message := 'cfg error: NE 107 C');

coUnit.TEST_FINISHED();
