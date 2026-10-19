coUnit.TEST('StationCore_PidControlsLeadSpeed_A7_PMI04');

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

stRetain.eMethod := E_ControlMethod.LevelPid;
stPidRetain.eRemoteMode := PL.E_DeviceMode.Auto;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 110,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.LevelPid, Message := 'LevelPid selected and ready');
fbDut.rLevel_m := 1.7;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 70,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[1] AND afbPump[1].xRunning, Message := 'lead running');
AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.LevelPid, Message := 'still LevelPid');
AssertEquals_REAL(Expected := fbPid.rOut_pct, Actual := fbDut.rSpeedSp_pct, Delta := 0.0,
                  Message := 'speed = PID output');
AssertTrue(Condition := fbPid.Mode = PL.E_DeviceMode.Auto, Message := 'LIC101 in Auto');
AssertTrue(Condition := (fbPid.stSts.stCommon.wStatus AND PL.GVL_Const.PID_STS_TRACKING) = 0,
           Message := 'PID not tracking');

coUnit.TEST_FINISHED();
