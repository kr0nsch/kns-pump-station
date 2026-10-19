coUnit.TEST('StationCfgCheck_LevelOrderBit_A18_PMI08');

stPid := GVL_StationDefaults.stLIC101Cfg;

stCfg.rLvlStopAssist_m := 1.7;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := GVL_Const.STN_CFG_LEVEL_ORDER, Actual := wErr, Message := 'stop assist above lead start');
stCfg.rLvlStopAssist_m := 1.4;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 2.3);
AssertEquals_WORD(Expected := GVL_Const.STN_CFG_LEVEL_ORDER, Actual := wErr, Message := 'H below assist start');

coUnit.TEST_FINISHED();
