coUnit.TEST('StationCore_PidHandoverKeepsOutput_A7_A8');

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

// ведущий 1 работает без остановки дольше tMaxContRun (4 ч)
afbPump[1].udiCurrentRunSeconds := TIME_TO_UDINT(stCfgLkg.tMaxContRun) / GVL_Const.STN_MS_PER_S + 1;
rMinSp := fbDut.rSpeedSp_pct;
FOR uiStep := 1 TO 120 DO
    Cycle(fbDut := fbDut, fbTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
          stRetain := stRetain, fbPid := fbPid, stPidCmd := stPidCmd, stPidCfg := stPidCfg,
          stPidRetain := stPidRetain, fbAlarms := fbAlarms, afbPump := afbPump, tStep := T#100MS, uiSteps := 1,
          xPlant := TRUE);
    rMinSp := MIN(rMinSp, fbDut.rSpeedSp_pct);
END_FOR

AssertEquals_REAL(Expected := 3.0, Actual := fbSink.ValueOf(eFind := E_StationEvent.ContRunHandover), Delta := 0.0,
                  Message := 'event 101007 with pump 3');
AssertTrue(Condition := fbDut.axRun[2] AND fbDut.axRun[3] AND NOT fbDut.axRun[1],
           Message := 'pump 1 released after the overlap');
AssertEquals_UINT(Expected := 3, Actual := fbDut.stSts.uiLeadPump, Message := 'replacement 3 becomes lead');
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
