coUnit.TEST('StationCfgCheck_PidStagingBit_A18');

stPid := GVL_StationDefaults.stLIC101Cfg;

stCfg.rAssistOff_pct := 88.1;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := GVL_Const.STN_CFG_PID_STAGING, Actual := wErr, Message := 'off above on - 10');
stCfg.rAssistOff_pct := 88.0;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := 0, Actual := wErr, Message := 'off exactly on - 10 passes');
stCfg.tAssistOn := T#4S;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := GVL_Const.STN_CFG_PID_STAGING, Actual := wErr, Message := 'tAssistOn below 5 s');

coUnit.TEST_FINISHED();
