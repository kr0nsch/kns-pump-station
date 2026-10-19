coUnit.TEST('PlantModel_OverflowTimeResolvedBySubsteps');

stCmd.xInflowOverride := TRUE;
stCmd.rInflowOverride_m3h := 250.0;
stCmd.xSetLevel := TRUE;
stCmd.rSetLevel_m := 4.595949;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertEquals_UDINT(Expected := 0, Actual := fbDut.stSts.udiOverflow_s, Message := 'no overflow yet');
fbTime.Advance(tStep := LTIME_TO_TIME(GVL_Const.SIM_DT_MAX));
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertEquals_REAL(Expected := stCfg.rLevelOverflow_m, Actual := fbDut.stSts.rLevel_m, Delta := R_EPS_M,
                  Message := 'level at overflow mark');
AssertEquals_UDINT(Expected := 1, Actual := fbDut.stSts.udiOverflow_s, Message := 'overflow 1.4 s by 200 ms substeps');

coUnit.TEST_FINISHED();
