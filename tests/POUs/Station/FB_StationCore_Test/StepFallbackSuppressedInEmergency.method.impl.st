coUnit.TEST('StationCore_StepFallbackSuppressedInEmergency_A7_A15_PMI28');

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
// старт ПЛК: последовательный пуск tPlcStart = 10 с (STEP подавлена), затем выдержка STEP 10 с
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 210,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.Stepped, Message := 'PID not ready: Stepped');
AssertTrue(Condition := (fbDut.stSts.wAlmActive AND 16#0080) <> 0, Message := 'KNS1.STEP active');
AssertTrue(Condition := (fbDut.stSts.wState AND GVL_Const.STN_ST_STEP_FALLBACK) <> 0, Message := 'wState step bit');
fbDut.rLevel_m := 4.05;
fbDut.xLevelH := TRUE;
fbDut.xLevelHH := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
      xPlant := TRUE);

itfAlm := fbAlarms.GetAlarm(uiIndex := E_StationAlarm.STEP - 1);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.SuppressedByDesign, Message := 'STEP suppressed in emergency');

coUnit.TEST_FINISHED();
