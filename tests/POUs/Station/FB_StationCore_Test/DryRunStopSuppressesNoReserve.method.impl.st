coUnit.TEST('StationCore_DryRunStopSuppressesNoReserve_A10_A11_A15_PMI21');

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

// отказ LT101, LS102: откачка всеми насосами
fbDut.xLevelValid := FALSE;
fbDut.xFloatHigh := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 110,
      xPlant := TRUE);

AssertTrue(Condition := afbPump[1].xRunning AND afbPump[2].xRunning AND afbPump[3].xRunning, Message := 'pumping');
// уровень у LS103: сухой ход, блокировка всех насосов — устройства недоступны и стоят
fbDut.xFloatHigh := FALSE;
fbDut.xFloatDry := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
      xPlant := TRUE);

AssertTrue(Condition := (fbDut.awInterlock[1] AND GVL_Const.KNS_ILK_DRY_RUN) <> 0, Message := 'dry run interlock');
FOR uiIdx := 1 TO 3 DO
    afbPump[uiIdx].xAvailable := FALSE;
END_FOR
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 200,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.DryRunStop, Message := 'DryRunStop');
AssertEquals_UINT(Expected := 0, Actual := fbDut.stSts.uiPumpsAvailable, Message := 'no pump available');
itfAlm := fbAlarms.GetAlarm(uiIndex := E_StationAlarm.NORES - 1);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.SuppressedByDesign, Message := 'NORES suppressed by dry run');
AssertEquals_WORD(Expected := 0, Actual := fbDut.stSts.wAlmActive AND 16#0004, Message := 'no LACK');
AssertEquals_WORD(Expected := 0, Actual := fbDut.stSts.wAlmUnack AND 16#000C, Message := 'no LACK, NORES unacked');
AssertEquals_WORD(Expected := 0, Actual := fbDut.stSts.wState AND GVL_Const.STN_ST_NO_RESERVE,
                  Message := 'wState: no reserve bit clear');

coUnit.TEST_FINISHED();
