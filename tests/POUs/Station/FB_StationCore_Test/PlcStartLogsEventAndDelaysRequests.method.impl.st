coUnit.TEST('StationCore_PlcStartLogsEventAndDelaysRequests_A13_PMI01_PMI35');

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

fbDut.rLevel_m := 2.0;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
      xPlant := TRUE);

AssertTrue(Condition := fbSink.Has(eFind := E_StationEvent.PlcStart), Message := 'event 101015');
AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.Restart, Message := 'restart at PLC start');
AssertTrue(Condition := (fbDut.stSts.wState AND GVL_Const.STN_ST_RESTART) <> 0, Message := 'wState restart bit');
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 98,
      xPlant := TRUE);

AssertFalse(Condition := fbDut.axRun[1] OR fbDut.axRun[2] OR fbDut.axRun[3], Message := 'no request before tPlcStart');
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 2,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[1], Message := 'lead requested after tPlcStart');
AssertEquals_UINT(Expected := 1, Actual := fbDut.stSts.uiLeadPump, Message := 'lead pump 1');

coUnit.TEST_FINISHED();
