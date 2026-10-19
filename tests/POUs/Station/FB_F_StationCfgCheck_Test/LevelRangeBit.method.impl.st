coUnit.TEST('StationCfgCheck_LevelRangeBit_A18_PMI08');

stPid := GVL_StationDefaults.stLIC101Cfg;

stCfg.rLvlStop_m := 0.85;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := GVL_Const.STN_CFG_LEVEL_RANGE, Actual := wErr, Message := 'stop below 0.90 m');
stCfg.rLvlStop_m := 1.0;
stCfg.rLvlStopAssist_m := 1.2;
stCfg.rLvlStartLead_m := 1.25;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := GVL_Const.STN_CFG_LEVEL_RANGE, Actual := wErr, Message := 'lead start gap 0.25 m');
stCfg.rLvlStartLead_m := 1.3;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := 0, Actual := wErr, Message := 'gap exactly 0.30 m passes');

coUnit.TEST_FINISHED();
