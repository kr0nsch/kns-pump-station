coUnit.TEST('PlantModel_PerPumpSignalsIsolated');

fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
FOR uiPump := 1 TO GVL_Const.STN_PUMP_COUNT DO
    // 1. Перегрев, протечка, «Местное», потеря связи насоса uiPump
    stFault := stFaultNone;
    stFault.axOverheat[uiPump] := TRUE;
    stFault.axLeak[uiPump] := TRUE;
    stFault.axLocal[uiPump] := TRUE;
    stFault.axVfdCommLoss[uiPump] := TRUE;
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
    axTs[1] := fbDut.stIo.xTS112;
    axTs[2] := fbDut.stIo.xTS122;
    axTs[3] := fbDut.stIo.xTS132;
    axMs[1] := fbDut.stIo.xMS113;
    axMs[2] := fbDut.stIo.xMS123;
    axMs[3] := fbDut.stIo.xMS133;
    axHs[1] := fbDut.stIo.xHS114;
    axHs[2] := fbDut.stIo.xHS124;
    axHs[3] := fbDut.stIo.xHS134;
    axFlt[1] := fbDut.stIo.xP101_FLT;
    axFlt[2] := fbDut.stIo.xP102_FLT;
    axFlt[3] := fbDut.stIo.xP103_FLT;
    axMbOk[1] := fbDut.stIo.xMbOk_RS485_1_S1;
    axMbOk[2] := fbDut.stIo.xMbOk_RS485_1_S2;
    axMbOk[3] := fbDut.stIo.xMbOk_RS485_1_S3;
    FOR uiJ := 1 TO GVL_Const.STN_PUMP_COUNT DO
        AssertTrue(Condition := axTs[uiJ] = (uiJ <> uiPump), Message := 'TS1n2 of its own pump only');
        AssertTrue(Condition := axMs[uiJ] = (uiJ = uiPump), Message := 'MS1n3 of its own pump only');
        AssertTrue(Condition := axHs[uiJ] = (uiJ = uiPump), Message := 'HS1n4 of its own pump only');
        AssertTrue(Condition := axFlt[uiJ] = (uiJ = uiPump), Message := 'overheat trips its own drive only');
        AssertTrue(Condition := axMbOk[uiJ] = (uiJ <> uiPump), Message := 'comm loss of its own slave only');
    END_FOR
    // 2. Авария ПЧ насоса uiPump (сначала исходное состояние: перегрев снят, ПЧ готовы)
    stFault := stFaultNone;
    stCmd.xResetPlant := TRUE;
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
    stFault.axVfdFault[uiPump] := TRUE;
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
    axFlt[1] := fbDut.stIo.xP101_FLT;
    axFlt[2] := fbDut.stIo.xP102_FLT;
    axFlt[3] := fbDut.stIo.xP103_FLT;
    auiFcode[1] := fbDut.stIo.uiP101_FCODE;
    auiFcode[2] := fbDut.stIo.uiP102_FCODE;
    auiFcode[3] := fbDut.stIo.uiP103_FCODE;
    FOR uiJ := 1 TO GVL_Const.STN_PUMP_COUNT DO
        AssertTrue(Condition := axFlt[uiJ] = (uiJ = uiPump), Message := 'drive fault of its own pump only');
    END_FOR
    AssertEquals_UINT(Expected := GVL_Const.SIM_VFD_FCODE_EXT, Actual := auiFcode[uiPump],
                      Message := 'own fault code 11');
    // 3. В работе только насос uiPump: частота, ток, реле «Работа»
    stFault := stFaultNone;
    stCmd.xResetPlant := TRUE;
    fbDut.axRun[uiPump] := TRUE;
    fbDut.auiFref[uiPump] := UI_FREF_50HZ;
    FOR uiI := 1 TO 12 DO
        fbTime.Advance(tStep := T_STEP);
        fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
    END_FOR
    axRfb[1] := fbDut.stIo.xP101_RFB;
    axRfb[2] := fbDut.stIo.xP102_RFB;
    axRfb[3] := fbDut.stIo.xP103_RFB;
    auiFact[1] := fbDut.stIo.uiP101_FACT;
    auiFact[2] := fbDut.stIo.uiP102_FACT;
    auiFact[3] := fbDut.stIo.uiP103_FACT;
    auiIt[1] := fbDut.stIo.uiIT111;
    auiIt[2] := fbDut.stIo.uiIT121;
    auiIt[3] := fbDut.stIo.uiIT131;
    FOR uiJ := 1 TO GVL_Const.STN_PUMP_COUNT DO
        AssertTrue(Condition := axRfb[uiJ] = (uiJ = uiPump), Message := 'run relay of its own pump only');
        AssertTrue(Condition := (auiFact[uiJ] = UI_FREF_50HZ) = (uiJ = uiPump) AND (auiFact[uiJ] = 0) = (uiJ <> uiPump),
                   Message := 'FACT of its own drive only');
        AssertTrue(Condition := (auiIt[uiJ] > 0) = (uiJ = uiPump), Message := 'current register of its own drive only');
    END_FOR
    fbDut.axRun[uiPump] := FALSE;
    FOR uiI := 1 TO 12 DO
        fbTime.Advance(tStep := T_STEP);
        fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
    END_FOR
END_FOR

coUnit.TEST_FINISHED();
