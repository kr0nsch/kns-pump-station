coUnit.TEST('StationCfgCheck_SetpointBit_A18_PMI08');

stPid := GVL_StationDefaults.stLIC101Cfg;

stCfg.rLevelSp_m := 2.3;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := GVL_Const.STN_CFG_SETPOINT, Actual := wErr, Message := 'setpoint 2.3 m');
stCfg.rLevelSp_m := 1.2;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := 0, Actual := wErr, Message := 'setpoint 1.2 m (limit) passes');

coUnit.TEST_FINISHED();
