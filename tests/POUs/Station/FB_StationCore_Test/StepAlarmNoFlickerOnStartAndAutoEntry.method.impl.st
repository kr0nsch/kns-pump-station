coUnit.TEST('StationCore_StepAlarmNoFlickerOnStartAndAutoEntry_A3_A7_A15_PMI01_PMI30');

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
FOR uiIdx := 1 TO 3 DO
    afbPump[uiIdx].xFollowRequests := TRUE;
END_FOR
// старт ПЛК в «Автомате» с выбранным ПИД
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#20MS, uiSteps := 600,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.LevelPid, Message := 'start: LevelPid');
AssertEquals_WORD(Expected := 0, Actual := fbDut.stSts.wAlmUnack AND 16#0080, Message := 'start: no KNS1.STEP');
// «Ручной», насос Н1 пущен оператором
stCmd.xSetManual := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#20MS, uiSteps := 5,
      xPlant := TRUE);

AssertTrue(Condition := afbPump[1].eMode = PL.E_DeviceMode.Manual, Message := 'pumps in Manual');
afbPump[1].xRunning := TRUE;
afbPump[1].rSpeedRef := 80.0;
afbPump[1].rSpeedAct := 80.0;
fbDut.rLevel_m := 1.5;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#20MS, uiSteps := 50,
      xPlant := TRUE);

// «Автомат»: насосы переходят в Auto в своём вызове
stCmd.xSetAuto := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#20MS, uiSteps := 100,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.LevelPid, Message := 'Auto entry: LevelPid');
AssertTrue(Condition := fbDut.axRun[1] AND afbPump[1].xRunning, Message := 'running pump adopted');
AssertEquals_WORD(Expected := 0, Actual := fbDut.stSts.wAlmUnack AND 16#0080, Message := 'Auto entry: no KNS1.STEP');

coUnit.TEST_FINISHED();
