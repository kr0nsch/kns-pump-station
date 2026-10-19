FOR uiStep := 1 TO uiSteps DO
    fbTime.Advance(tStep := T#100MS);
    fbAi(rIn := rIn_mA, xChannelFault := FALSE, itfTime := fbTime, stCmd := stAiCmd, stCfg := stAiCfg);
    fbDut.rLevel_m := fbAi.rValue_eu;
    fbDut.xLevelValid := fbAi.xValid;
    fbDut.eLevelNe107 := fbAi.stSts.stCommon.eNe107;
    fbDut.xLevelL := fbAi.xL;
    fbDut.xLevelLL := fbAi.xLL;
    fbDut.xLevelH := fbAi.xH;
    fbDut.xLevelHH := fbAi.xHH;
    fbDut(itfTime := fbTime, stCfg := stCfg);
END_FOR
