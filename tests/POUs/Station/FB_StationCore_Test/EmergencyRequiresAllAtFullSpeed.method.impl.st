coUnit.TEST('StationCore_EmergencyRequiresAllAtFullSpeed_A10_PMI20');

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

fbDut.rLevel_m := 4.05;
fbDut.xLevelH := TRUE;
fbDut.xLevelHH := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 110,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.Emergency, Message := 'Emergency');
AssertEquals_UINT(Expected := 3, Actual := fbDut.stSts.uiPumpsRequired, Message := 'three pumps required');
AssertTrue(Condition := fbDut.axRun[1] AND fbDut.axRun[2] AND fbDut.axRun[3], Message := 'all requested');
AssertEquals_REAL(Expected := 100.0, Actual := fbDut.rSpeedSp_pct, Delta := 0.0, Message := 'full speed');
AssertTrue(Condition := (fbDut.stSts.wAlmActive AND 16#0001) <> 0, Message := 'KNS1.EHL active');

coUnit.TEST_FINISHED();
