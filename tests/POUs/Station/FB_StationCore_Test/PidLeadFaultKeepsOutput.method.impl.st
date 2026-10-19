coUnit.TEST('StationCore_PidLeadFaultKeepsOutput_A7_A9_PMI13');

StartPidTwoPumps(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist,
                 stCfgLkg := stCfgLkg, stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd,
                 stPidCfg := stPidCfg, stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump,
                 itfEvents := fbSink);
AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.LevelPid, Message := 'LevelPid before the event');
AssertTrue(Condition := fbDut.stSts.uiLeadPump = 1 AND afbPump[1].xRunning AND afbPump[2].xRunning
                        AND NOT afbPump[3].xRunning, Message := 'lead 1 and assist 2 running, 3 standby');
AssertTrue(Condition := (fbPid.stSts.stCommon.wStatus AND PL.GVL_Const.PID_STS_TRACKING) = 0,
           Message := 'PID controls before the event');
AssertTrue(Condition := fbPid.rOut_pct > 80.0 AND fbPid.rOut_pct < 98.0, Message := 'PID output high, below 98 %');
rOutBefore := fbPid.rOut_pct;

// авария ПЧ ведущего (USAGE §3): устройство останавливает насос, задание на ПЧ 0, насос недоступен
afbPump[1].xFault := TRUE;
afbPump[1].xRunning := FALSE;
afbPump[1].xSpeedAuto := FALSE;
afbPump[1].rSpeedRef := 0.0;
afbPump[1].rSpeedAct := 0.0;
Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
      stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
      stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
      xPlant := TRUE);

AssertTrue(Condition := fbDut.axRun[2] AND fbDut.axRun[3] AND NOT fbDut.axRun[1],
           Message := 'faulted lead released, standby 3 requested in the same cycle');
AssertEquals_UINT(Expected := 2, Actual := fbDut.stSts.uiLeadPump, Message := 'assist 2 becomes lead');
AssertEquals_REAL(Expected := rOutBefore, Actual := fbDut.rSpeedSp_pct, Delta := 0.5,
                  Message := 'fault cycle: speed setpoint keeps the PID output');
rMinSp := fbDut.rSpeedSp_pct;
FOR uiStep := 1 TO 30 DO
    Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
          stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
          stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
          xPlant := TRUE);
    rMinSp := MIN(rMinSp, fbDut.rSpeedSp_pct);
END_FOR

AssertTrue(Condition := fbDut.stSts.eControlAct = E_ControlAct.LevelPid, Message := 'still LevelPid');
AssertTrue(Condition := (fbPid.stSts.stCommon.wStatus AND PL.GVL_Const.PID_STS_TRACKING) = 0,
           Message := 'PID controls via the new lead');
AssertTrue(Condition := rMinSp >= rOutBefore - 2.0, Message := 'speed setpoint did not collapse');
AssertEquals_REAL(Expected := rOutBefore, Actual := fbPid.rOut_pct, Delta := 5.0,
                  Message := 'PID output near the previous one');
AssertEquals_REAL(Expected := rOutBefore, Actual := afbPump[2].rSpeedRef, Delta := 5.0,
                  Message := 'pump 2 speed near the previous output');
AssertEquals_REAL(Expected := rOutBefore, Actual := afbPump[3].rSpeedRef, Delta := 5.0,
                  Message := 'pump 3 speed near the previous output');
AssertEquals_UINT(Expected := 2, Actual := fbDut.stSts.uiPumpsRunning, Message := 'two pumps running');

coUnit.TEST_FINISHED();
