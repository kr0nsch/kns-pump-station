coUnit.TEST('StationCfgCheck_AlarmBit_A18');

stPid := GVL_StationDefaults.stLIC101Cfg;

pRaw := ADR(stCfg.astAlarm[5].ePriority);
pRaw^ := 9;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := GVL_Const.STN_CFG_ALARM, Actual := wErr, Message := 'priority out of enum');

coUnit.TEST_FINISHED();
