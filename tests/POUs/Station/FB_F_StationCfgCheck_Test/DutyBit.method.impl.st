coUnit.TEST('StationCfgCheck_DutyBit_A18');

stPid := GVL_StationDefaults.stLIC101Cfg;

stCfg.uiDutyMax := 0;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := GVL_Const.STN_CFG_DUTY, Actual := wErr, Message := 'duty 0');
stCfg.uiDutyMax := 4;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := GVL_Const.STN_CFG_DUTY, Actual := wErr, Message := 'duty 4');

coUnit.TEST_FINISHED();
