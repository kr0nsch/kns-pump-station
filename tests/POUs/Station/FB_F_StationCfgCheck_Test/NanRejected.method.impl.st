coUnit.TEST('StationCfgCheck_NanRejected_A18');

stPid := GVL_StationDefaults.stLIC101Cfg;

uBits.dwValue := 16#7FC00000;
stCfg.rLvlStop_m := uBits.rValue;
stCfg.rUnderloadSpeed_pct := uBits.rValue;
stCfg.rLevelSp_m := uBits.rValue;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := GVL_Const.STN_CFG_LEVEL_ORDER OR GVL_Const.STN_CFG_LEVEL_RANGE
                  OR GVL_Const.STN_CFG_UNDERLOAD OR GVL_Const.STN_CFG_SETPOINT, Actual := wErr,
                  Message := 'NaN fails order, range, underload, setpoint');

coUnit.TEST_FINISHED();
