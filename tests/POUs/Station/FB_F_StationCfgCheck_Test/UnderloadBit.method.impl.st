coUnit.TEST('StationCfgCheck_UnderloadBit_A18');

stPid := GVL_StationDefaults.stLIC101Cfg;

stCfg.rUnderload_A := 30.5;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := GVL_Const.STN_CFG_UNDERLOAD, Actual := wErr, Message := 'underload 30.5 A');
stCfg.rUnderload_A := 0.0;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := 0, Actual := wErr, Message := 'underload 0: disabled, valid');

coUnit.TEST_FINISHED();
