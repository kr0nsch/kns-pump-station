coUnit.TEST('StationCfgCheck_FloatCheckBit_A18');

stPid := GVL_StationDefaults.stLIC101Cfg;

stCfg.rLdev103Off_m := 0.36;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := GVL_Const.STN_CFG_FLOAT_CHECK, Actual := wErr, Message := 'rLdev103Off 0.36 m');

coUnit.TEST_FINISHED();
