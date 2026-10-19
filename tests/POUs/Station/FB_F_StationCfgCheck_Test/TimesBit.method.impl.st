coUnit.TEST('StationCfgCheck_TimesBit_A18');

stPid := GVL_StationDefaults.stLIC101Cfg;

stCfg.tSeqStep := T#4S;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := GVL_Const.STN_CFG_TIMES, Actual := wErr, Message := 'tSeqStep 4 s');
stCfg.tSeqStep := T#15S;
stCfg.tV1Overrun := T#61M;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := GVL_Const.STN_CFG_TIMES, Actual := wErr, Message := 'tV1Overrun 61 min');

coUnit.TEST_FINISHED();
