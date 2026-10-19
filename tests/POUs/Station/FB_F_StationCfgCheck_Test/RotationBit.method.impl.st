coUnit.TEST('StationCfgCheck_RotationBit_A18');

stPid := GVL_StationDefaults.stLIC101Cfg;

pRaw := ADR(stCfg.eRotation);
pRaw^ := 9;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := GVL_Const.STN_CFG_ROTATION, Actual := wErr, Message := 'rotation out of enum');
stCfg.eRotation := E_RotationMode.Cyclic;
stCfg.tMaxContRun := T#5M;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := GVL_Const.STN_CFG_ROTATION, Actual := wErr, Message := 'tMaxContRun 5 min');
stCfg.tMaxContRun := T#0S;
wErr := F_StationCfgCheck(stCfg := stCfg, stPidCfg := stPid, rLvlL_m := 0.8, rLvlH_m := 3.5);

AssertEquals_WORD(Expected := 0, Actual := wErr, Message := 'tMaxContRun 0: disabled, valid');

coUnit.TEST_FINISHED();
