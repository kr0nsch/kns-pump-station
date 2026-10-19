coUnit.TEST('StationCore_CommandPulsesClearedAndCounted_A19_PMI30_PMI36');

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
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
      xPlant := TRUE);

uiSeq0 := fbDut.stSts.uiCmdSeq;
stCmd.xSetAuto := TRUE;
stCmd.xAckAll := TRUE;
stCmd.xSilence := TRUE;
stCmd.wAckReq := 16#0002;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
      xPlant := TRUE);

AssertFalse(Condition := stCmd.xSetAuto OR stCmd.xAckAll OR stCmd.xSilence, Message := 'pulses cleared');
AssertEquals_WORD(Expected := 0, Actual := stCmd.wAckReq, Message := 'mask cleared');
AssertEquals_UINT(Expected := uiSeq0 + 4, Actual := fbDut.stSts.uiCmdSeq, Message := 'four commands counted');
AssertTrue(Condition := fbDut.stSts.eCmdResult = PL.E_CmdResult.Accepted, Message := 'accepted');
AssertTrue(Condition := fbDut.stSts.eMode = E_StationMode.Auto, Message := 'station in Auto');
AssertTrue(Condition := fbDut.xAckAllReq, Message := 'devices ack request');
AssertTrue(Condition := fbSink.Has(eFind := E_StationEvent.StationAuto) AND fbSink.Has(eFind := E_StationEvent.AckAll)
           AND fbSink.Has(eFind := E_StationEvent.Silence), Message := 'events 101001, 101022, 101023');
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
      xPlant := TRUE);

AssertFalse(Condition := fbDut.xAckAllReq, Message := 'ack request lasts one cycle');

coUnit.TEST_FINISHED();
