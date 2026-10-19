coUnit.TEST('StationCore_PowerLostSuppressesLackNoresAts_A13_A15_PMI33');

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

fbDut.xPowerOk := FALSE;
afbPump[1].xAvailable := FALSE;
afbPump[2].xAvailable := FALSE;
afbPump[3].xAvailable := FALSE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 120,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.PowerLost, Message := 'PowerLost');
AssertTrue(Condition := (fbDut.stSts.wState AND GVL_Const.STN_ST_POWER_LOST) <> 0, Message := 'wState power lost');
itfAlm := fbAlarms.GetAlarm(uiIndex := E_StationAlarm.NORES - 1);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.SuppressedByDesign, Message := 'NORES suppressed by design');
AssertEquals_WORD(Expected := 0, Actual := fbDut.stSts.wAlmUnack AND 16#001C, Message := 'no LACK, NORES, ATS unacked');
AssertTrue(Condition := fbSink.Has(eFind := E_StationEvent.PowerLost), Message := 'event 101008');

coUnit.TEST_FINISHED();
