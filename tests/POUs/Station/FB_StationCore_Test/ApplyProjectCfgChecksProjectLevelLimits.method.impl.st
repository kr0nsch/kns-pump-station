coUnit.TEST('StationCore_ApplyProjectCfgChecksProjectLevelLimits_A18');

stPidCfg := GVL_StationDefaults.stLIC101Cfg;
stRetain.eMode := E_StationMode.Auto;
fbDut.aitfPump[1] := afbPump[1];
fbDut.aitfPump[2] := afbPump[2];
fbDut.aitfPump[3] := afbPump[3];
fbDut.axCommOk[1] := TRUE;
fbDut.axCommOk[2] := TRUE;
fbDut.axCommOk[3] := TRUE;
fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.3;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
// наладчик поднял L LT101 до 1,1 м и останов станции до 1,2 м (порядок отметок соблюдён)
fbDut.rLvlL_m := 1.1;
fbDut.rLvlH_m := 3.5;
fbDut.rLvlLProject_m := 0.8;
fbDut.rLvlHProject_m := 3.5;
fbDut.xPowerOk := TRUE;
stCfgPersist.rLvlStop_m := 1.2;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 110,
      xPlant := TRUE);

AssertEquals_WORD(Expected := 0, Actual := fbDut.stSts.wCfgErr, Message := 'operator cfg accepted');
AssertEquals_REAL(Expected := 1.2, Actual := stCfgLkg.rLvlStop_m, Delta := 0.0, Message := 'LKG: stop 1.2 m');
fbSink.Clear();

// команда: в этом цикле LT101 ещё с L 1,1 м (PRG_Devices восстановит её после станции)
fbDut.xApplyProjectCfg := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
      xPlant := TRUE);

fbDut.xApplyProjectCfg := FALSE;
AssertEquals_WORD(Expected := 0, Actual := fbDut.stSts.wCfgErr, Message := 'command cycle: no cfg error');
AssertFalse(Condition := fbDut.stSts.eNe107 = PL.E_Ne107Status.CheckFunction,
            Message := 'command cycle: no NE 107 check function');
AssertEquals_REAL(Expected := 1.0, Actual := stCfgLkg.rLvlStop_m, Delta := 0.0,
                  Message := 'command cycle: defaults are LKG');
// следующие циклы — L/H LT101 уставок проекта
fbDut.rLvlL_m := 0.8;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 10,
      xPlant := TRUE);

AssertEquals_UINT(Expected := 1, Actual := fbSink.CountOf(eFind := E_StationEvent.CfgChanged),
                  Message := 'one event 101017');
AssertEquals_REAL(Expected := 0.0, Actual := fbSink.ValueOf(eFind := E_StationEvent.CfgChanged), Delta := 0.0,
                  Message := 'event 101017 of the command: value 0');
AssertEquals_REAL(Expected := 1.0, Actual := stCfgLkg.rLvlStop_m, Delta := 0.0, Message := 'LKG: defaults');

coUnit.TEST_FINISHED();
