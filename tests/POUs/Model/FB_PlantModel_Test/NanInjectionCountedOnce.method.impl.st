coUnit.TEST('PlantModel_NanInjectionCountedOnce');

uBits.dwValue := DW_NAN;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
stFault.arAiForced_mA[GVL_Const.SIM_AI_PT201] := uBits.rValue;
FOR uiI := 1 TO 3 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertEquals_UDINT(Expected := 1, Actual := fbDut.stSts.udiFaultSeq, Message := 'forced NaN counted once');
stFault.rH2S_mgm3 := uBits.rValue;
FOR uiI := 1 TO 3 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertEquals_UDINT(Expected := 2, Actual := fbDut.stSts.udiFaultSeq, Message := 'gas NaN counted once');
// неконечная концентрация — ток отказа снизу (M7), не NaN во входе ПЛК
AssertTrue(Condition := PL.F_IsFinite(rIn := fbDut.stIo.rAT401_mA), Message := 'AT401 current finite');
AssertEquals_REAL(Expected := GVL_Const.SIM_MA_FAIL_LOW, Actual := fbDut.stIo.rAT401_mA, Delta := 0.0,
                  Message := 'NaN gas -> fail-low current');
stFault.arAiForced_mA[GVL_Const.SIM_AI_PT201] := 4.0;
FOR uiI := 1 TO 3 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertEquals_UDINT(Expected := 3, Actual := fbDut.stSts.udiFaultSeq, Message := 'NaN to finite counted once');

coUnit.TEST_FINISHED();
