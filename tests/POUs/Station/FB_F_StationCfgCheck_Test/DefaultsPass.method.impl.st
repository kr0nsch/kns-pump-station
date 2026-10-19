coUnit.TEST('StationCfgCheck_DefaultsPass_A18');

stPid := GVL_StationDefaults.stLIC101Cfg;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := 0, Actual := wErr, Message := 'defaults pass');

coUnit.TEST_FINISHED();
