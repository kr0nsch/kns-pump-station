coUnit.TEST('StationCfgCheck_SpeedBit_A18');

stPid := GVL_StationDefaults.stLIC101Cfg;

stCfg.rStepSpeed_pct := 59.9;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := GVL_Const.STN_CFG_SPEED, Actual := wErr, Message := 'speed 59.9 %');
stCfg.rStepSpeed_pct := 100.1;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := GVL_Const.STN_CFG_SPEED, Actual := wErr, Message := 'speed 100.1 %');

coUnit.TEST_FINISHED();
