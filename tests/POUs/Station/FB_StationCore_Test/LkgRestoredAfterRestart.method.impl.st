coUnit.TEST('StationCore_LkgRestoredAfterRestart_A18_PMI35');

stPidCfg := GVL_StationDefaults.stLIC101Cfg;
stRetain.eMode := E_StationMode.Auto;
fbDutBefore.aitfPump[1] := afbPump[1];
fbDutBefore.aitfPump[2] := afbPump[2];
fbDutBefore.aitfPump[3] := afbPump[3];
fbDutBefore.axCommOk[1] := TRUE;
fbDutBefore.axCommOk[2] := TRUE;
fbDutBefore.axCommOk[3] := TRUE;
fbDutBefore.itfEvents := fbSinkBefore;
fbDutBefore.rLevel_m := 1.2;
fbDutBefore.xLevelValid := TRUE;
fbDutBefore.eLevelNe107 := PL.E_Ne107Status.Good;
fbDutBefore.rLvlL_m := 0.8;
fbDutBefore.rLvlH_m := 3.5;
fbDutBefore.xPowerOk := TRUE;

// до перезапуска: старт, корректная правка 1,8 м, затем неверная 2,5 м (вне пределов задания LIC101)
fbTime.Advance(tStep := T#100MS);
fbDutBefore(itfTime := fbTime, stCmd := stCmdBefore, stCfgPersist := stCfgPersist, stCfgLkg := stLkgBefore,
            stCfgLkgRetain := stCfgLkgRetain, stRetain := stRetain, fbLIC101 := fbPidBefore,
            stLIC101Cmd := stPidCmdBefore, stLIC101Cfg := stPidCfg, stLIC101Retain := stPidRetain,
            fbAlarms := fbAlmBefore);
stCfgPersist.rLevelSp_m := 1.8;
fbTime.Advance(tStep := T#100MS);
fbDutBefore(itfTime := fbTime, stCmd := stCmdBefore, stCfgPersist := stCfgPersist, stCfgLkg := stLkgBefore,
            stCfgLkgRetain := stCfgLkgRetain, stRetain := stRetain, fbLIC101 := fbPidBefore,
            stLIC101Cmd := stPidCmdBefore, stLIC101Cfg := stPidCfg, stLIC101Retain := stPidRetain,
            fbAlarms := fbAlmBefore);
AssertEquals_REAL(Expected := 1.8, Actual := stCfgLkgRetain.rLevelSp_m, Delta := 0.0,
                  Message := 'accepted setpoint saved in retained LKG');
stCfgPersist.rLevelSp_m := 2.5;
fbTime.Advance(tStep := T#100MS);
fbDutBefore(itfTime := fbTime, stCmd := stCmdBefore, stCfgPersist := stCfgPersist, stCfgLkg := stLkgBefore,
            stCfgLkgRetain := stCfgLkgRetain, stRetain := stRetain, fbLIC101 := fbPidBefore,
            stLIC101Cmd := stPidCmdBefore, stLIC101Cfg := stPidCfg, stLIC101Retain := stPidRetain,
            fbAlarms := fbAlmBefore);
AssertEquals_REAL(Expected := 1.8, Actual := stLkgBefore.rLevelSp_m, Delta := 0.0, Message := 'LKG keeps 1.8');
AssertEquals_REAL(Expected := 1.8, Actual := stCfgLkgRetain.rLevelSp_m, Delta := 0.0,
                  Message := 'invalid edit not saved in retained LKG');

// перезапуск: новый экземпляр ядра, GVL_Station — умолчания, GVL_Persist — прежний
fbDutAfter.aitfPump[1] := afbPump[1];
fbDutAfter.aitfPump[2] := afbPump[2];
fbDutAfter.aitfPump[3] := afbPump[3];
fbDutAfter.axCommOk[1] := TRUE;
fbDutAfter.axCommOk[2] := TRUE;
fbDutAfter.axCommOk[3] := TRUE;
fbDutAfter.itfEvents := fbSinkAfter;
fbDutAfter.rLevel_m := 1.2;
fbDutAfter.xLevelValid := TRUE;
fbDutAfter.eLevelNe107 := PL.E_Ne107Status.Good;
fbDutAfter.rLvlL_m := 0.8;
fbDutAfter.rLvlH_m := 3.5;
fbDutAfter.xPowerOk := TRUE;
fbTime.Advance(tStep := T#100MS);
fbDutAfter(itfTime := fbTime, stCmd := stCmdAfter, stCfgPersist := stCfgPersist, stCfgLkg := stLkgAfter,
           stCfgLkgRetain := stCfgLkgRetain, stRetain := stRetain, fbLIC101 := fbPidAfter,
           stLIC101Cmd := stPidCmdAfter, stLIC101Cfg := stPidCfg, stLIC101Retain := stPidRetain,
           fbAlarms := fbAlmAfter);

AssertEquals_REAL(Expected := 1.8, Actual := stLkgAfter.rLevelSp_m, Delta := 0.0,
                  Message := 'after restart: LKG restored from retained copy, not project defaults');
AssertEquals_REAL(Expected := 1.8, Actual := fbDutAfter.stSts.rLevelSp_m, Delta := 0.0,
                  Message := 'after restart: status setpoint 1.8');
AssertEquals_WORD(Expected := GVL_Const.STN_CFG_SETPOINT, Actual := fbDutAfter.stSts.wCfgErr,
                  Message := 'after restart: invalid edit still flagged');
AssertEquals_REAL(Expected := 2.5, Actual := stCfgPersist.rLevelSp_m, Delta := 0.0,
                  Message := 'persisted edit kept for the operator');
AssertEquals_UINT(Expected := 0, Actual := fbSinkAfter.CountOf(eFind := E_StationEvent.CfgChanged),
                  Message := 'no event 101017 at start');

coUnit.TEST_FINISHED();
