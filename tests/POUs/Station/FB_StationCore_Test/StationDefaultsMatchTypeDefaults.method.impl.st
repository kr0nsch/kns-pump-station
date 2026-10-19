coUnit.TEST('StationCore_StationDefaultsMatchTypeDefaults_A18');

stDef := GVL_StationDefaults.stStationCfg;
AssertEquals_UINT(Expected := 0, Actual := fbDut.ChangedParam(stOld := stType, stNew := stDef),
                  Message := 'station defaults equal type defaults');
AssertEquals_REAL(Expected := 1.0, Actual := stDef.rLvlStop_m, Delta := 0.0, Message := 'defaults are not zeros');
stDef.astAlarm[3].tOnDelay := T#11S;
AssertEquals_UINT(Expected := GVL_Const.STN_CFG_PARAM_ALARMS,
                  Actual := fbDut.ChangedParam(stOld := stType, stNew := stDef),
                  Message := 'alarm table difference detected');
stDef.tSeqStep := T#16S;
AssertEquals_UINT(Expected := 19, Actual := fbDut.ChangedParam(stOld := stType, stNew := stDef),
                  Message := 'first difference: parameter 19 (tSeqStep)');
AssertEquals_UDINT(Expected := (GVL_Const.STN_CFG_RESERVE_REAL_LAST + 1) * 4, Actual := SIZEOF(stType.arReserve),
                   Message := 'arReserve bound matches constant');
AssertEquals_UDINT(Expected := (GVL_Const.STN_CFG_RESERVE_SHORT_LAST + 1) * 2, Actual := SIZEOF(stType.auiReserve),
                   Message := 'auiReserve bound matches constant');

coUnit.TEST_FINISHED();
