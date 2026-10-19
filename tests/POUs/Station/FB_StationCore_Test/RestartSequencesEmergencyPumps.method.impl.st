coUnit.TEST('StationCore_RestartSequencesEmergencyPumps_A10_A13_PMI34');

stPidCfg := GVL_StationDefaults.stLIC101Cfg;
stRetain.eMode := E_StationMode.Auto;
stCfgPersist.rStepSpeed_pct := 80.0;                  // частота ступенчатого отличается от полной
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

// пропадание напряжения: насосы недоступны; за время без питания уровень дошёл до HH и LS102
fbDut.xPowerOk := FALSE;
FOR uiIdx := 1 TO 3 DO
    afbPump[uiIdx].xAvailable := FALSE;
END_FOR
fbDut.rLevel_m := 4.1;
fbDut.xLevelH := TRUE;
fbDut.xLevelHH := TRUE;
fbDut.xFloatHigh := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 50,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.PowerLost, Message := 'PowerLost');
// восстановление: задержка tPwrRestart 10 с, затем шаги по tSeqStep 15 с
fbDut.xPowerOk := TRUE;
FOR uiIdx := 1 TO 3 DO
    afbPump[uiIdx].xAvailable := TRUE;
END_FOR
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 105,
      xPlant := TRUE);

uiReq := BOOL_TO_UINT(fbDut.axRun[1]) + BOOL_TO_UINT(fbDut.axRun[2]) + BOOL_TO_UINT(fbDut.axRun[3]);
AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.Restart, Message := 'Restart: step 1');
AssertEquals_UINT(Expected := 1, Actual := uiReq, Message := 'step 1: one request');
AssertEquals_UINT(Expected := 3, Actual := fbDut.stSts.uiPumpsRequired, Message := 'emergency: all pumps required');
AssertEquals_REAL(Expected := 100.0, Actual := fbDut.rSpeedSp_pct, Delta := 0.0, Message := 'emergency: full speed');
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 245,
      xPlant := TRUE);

uiReq := BOOL_TO_UINT(fbDut.axRun[1]) + BOOL_TO_UINT(fbDut.axRun[2]) + BOOL_TO_UINT(fbDut.axRun[3]);
AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.Restart, Message := 'Restart: step 2');
AssertEquals_UINT(Expected := 2, Actual := uiReq, Message := 'step 2: third pump waits for tSeqStep');
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 70,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[1] AND fbDut.axRun[2] AND fbDut.axRun[3], Message := 'step 3: all requested');
AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.Emergency, Message := 'sequence done: Emergency');
AssertEquals_REAL(Expected := 3.0, Actual := fbSink.ValueOf(eFind := E_StationEvent.RestartDone), Delta := 0.0,
                  Message := 'event 101010: three starts');

coUnit.TEST_FINISHED();
