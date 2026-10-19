coUnit.TEST('StationCore_FloatModeStartsAllOnLs102_A11_PMI21_PMI25');

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

fbDut.xLevelValid := FALSE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.Float, Message := 'Float');
AssertEquals_UINT(Expected := 0, Actual := fbDut.stSts.uiPumpsRequired, Message := 'waiting for LS102');
fbDut.xFloatHigh := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 110,
      xPlant := TRUE);

AssertEquals_UINT(Expected := 3, Actual := fbDut.stSts.uiPumpsRequired, Message := 'LS102: all pumps');
AssertTrue(Condition := fbDut.axRun[1] AND fbDut.axRun[2] AND fbDut.axRun[3], Message := 'all requested');
AssertEquals_REAL(Expected := 100.0, Actual := fbDut.rSpeedSp_pct, Delta := 0.0, Message := 'full speed');
itfAlm := fbAlarms.GetAlarm(uiIndex := E_StationAlarm.EHL - 1);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.SuppressedByDesign, Message := 'EHL suppressed in float mode');
AssertTrue(Condition := (fbDut.stSts.wAlmActive AND 16#0020) <> 0, Message := 'KNS1.FLOAT active');
AssertTrue(Condition := fbDut.stSts.eNe107 = PL.E_Ne107Status.OutOfSpecification, Message := 'NE 107 S');

coUnit.TEST_FINISHED();
