coUnit.TEST('StationCore_OverheatTripIsAts_A9_A10_PMI16');

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

fbDut.rLevel_m := 1.7;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 60,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[1] AND afbPump[1].xRunning, Message := 'lead 1 running');
// TS112: блокировка станции в этом цикле
fbDut.axOverheat[1] := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#20MS, uiSteps := 1,
      xPlant := TRUE);

AssertTrue(Condition := (fbDut.awInterlock[1] AND GVL_Const.KNS_ILK_OVERHEAT) <> 0, Message := 'overheat interlock');
// устройство выполнило блокировку: недоступно и стоит; авария ПЧ — только через 0,2 с
afbPump[1].xAvailable := FALSE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#20MS, uiSteps := 10,
      xPlant := TRUE);

afbPump[1].xFault := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#20MS, uiSteps := 5,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[2] AND NOT fbDut.axRun[1], Message := 'replacement pump 2');
AssertTrue(Condition := (fbDut.stSts.wAlmActive AND 16#0010) <> 0, Message := 'KNS1.ATS active');
AssertTrue(Condition := (fbDut.stSts.wState AND GVL_Const.STN_ST_ATS) <> 0, Message := 'wState ATS bit');
AssertEquals_REAL(Expected := 2.0, Actual := fbSink.ValueOf(eFind := E_StationEvent.AtsPumpIn), Delta := 0.0,
                  Message := 'event 101006 with pump 2');
AssertEquals_WORD(Expected := 0, Actual := fbDut.stSts.wAlmActive AND 16#0200, Message := 'no KNS1.UL1');
// остыл, отказ сброшен, насос снова доступен — АВР снят
fbDut.axOverheat[1] := FALSE;
afbPump[1].xFault := FALSE;
afbPump[1].xAvailable := TRUE;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#20MS, uiSteps := 2,
      xPlant := TRUE);

AssertEquals_WORD(Expected := 0, Actual := fbDut.stSts.wAlmActive AND 16#0010, Message := 'ATS clears when available');
AssertTrue(Condition := fbDut.stSts.aeRole[1] = E_PumpRole.Standby, Message := 'pump 1 standby after reset');

coUnit.TEST_FINISHED();
