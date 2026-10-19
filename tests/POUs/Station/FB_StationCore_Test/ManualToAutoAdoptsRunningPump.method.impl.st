coUnit.TEST('StationCore_ManualToAutoAdoptsRunningPump_A3_PMI30');

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
afbPump[1].eMode := PL.E_DeviceMode.Manual;
afbPump[2].eMode := PL.E_DeviceMode.Manual;
afbPump[3].eMode := PL.E_DeviceMode.Manual;
afbPump[1].xRunning := TRUE;
afbPump[1].rSpeedRef := 88.0;
afbPump[1].xFollowRequests := TRUE;
fbDut.rLevel_m := 1.5;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 110,
      xPlant := TRUE);

AssertEquals_REAL(Expected := 88.0, Actual := fbDut.rSpeedSp_pct, Delta := 0.0,
                  Message := 'Manual: speed tracks the pump');
stCmd.xSetAuto := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
      xPlant := FALSE);

AssertTrue(Condition := fbDut.axRun[1], Message := 'running pump requested in the same cycle');
AssertTrue(Condition := afbPump[1].uiRequestModeCalls = 1 AND afbPump[2].uiRequestModeCalls = 1,
           Message := 'Auto requested');
AssertEquals_UINT(Expected := 1, Actual := fbDut.stSts.uiPumpsRequired, Message := 'stepped init from running pumps');
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 100,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[1] AND NOT fbDut.axRun[2], Message := 'pump kept, no extra start');

coUnit.TEST_FINISHED();
