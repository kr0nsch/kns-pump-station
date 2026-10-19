coUnit.TEST('PlantModel_AiFaultCurrents');

fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertEquals_REAL(Expected := 7.84, Actual := fbDut.stIo.rLT101_mA, Delta := R_EPS_MA, Message := 'no injection');
stFault.aeAiFault[GVL_Const.SIM_AI_LT101] := E_SimAiFault.WireBreak;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.stIo.rLT101_mA, Delta := 0.0, Message := 'wire break 0 mA');
stFault.aeAiFault[GVL_Const.SIM_AI_LT101] := E_SimAiFault.FailLow;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertEquals_REAL(Expected := GVL_Const.SIM_MA_FAIL_LOW, Actual := fbDut.stIo.rLT101_mA, Delta := 0.0,
                  Message := '3.0 mA');
stFault.aeAiFault[GVL_Const.SIM_AI_LT101] := E_SimAiFault.FailHigh;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertEquals_REAL(Expected := GVL_Const.SIM_MA_FAIL_HIGH, Actual := fbDut.stIo.rLT101_mA, Delta := 0.0,
                  Message := '22 mA');
stFault.aeAiFault[GVL_Const.SIM_AI_LT101] := E_SimAiFault.UnderRange;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertEquals_REAL(Expected := GVL_Const.SIM_MA_UNDER_RANGE, Actual := fbDut.stIo.rLT101_mA, Delta := 0.0,
                  Message := '3.7 mA');
stFault.aeAiFault[GVL_Const.SIM_AI_LT101] := E_SimAiFault.OverRange;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertEquals_REAL(Expected := GVL_Const.SIM_MA_OVER_RANGE, Actual := fbDut.stIo.rLT101_mA, Delta := 0.0,
                  Message := '20.8 mA');
stFault.aeAiFault[GVL_Const.SIM_AI_LT101] := E_SimAiFault.Forced;
stFault.arAiForced_mA[GVL_Const.SIM_AI_LT101] := 12.5;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertEquals_REAL(Expected := 12.5, Actual := fbDut.stIo.rLT101_mA, Delta := 0.0, Message := 'forced 12.5 mA');
stFault.aeAiFault[GVL_Const.SIM_AI_LT101] := E_SimAiFault.None;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
stFault.aeAiFault[GVL_Const.SIM_AI_LT101] := E_SimAiFault.Freeze;
stCmd.xSetLevel := TRUE;
stCmd.rSetLevel_m := 2.0;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertEquals_REAL(Expected := 7.84, Actual := fbDut.stIo.rLT101_mA, Delta := R_EPS_MA, Message := 'frozen at 7.84 mA');
stFault.aeAiFault[GVL_Const.SIM_AI_LT101] := E_SimAiFault.None;
stFault.aeAiFault[GVL_Const.SIM_AI_PT201] := E_SimAiFault.FailHigh;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertEquals_REAL(Expected := 10.4, Actual := fbDut.stIo.rLT101_mA, Delta := R_EPS_MA,
                  Message := 'LT101 follows 2.0 m');
AssertEquals_REAL(Expected := GVL_Const.SIM_MA_FAIL_HIGH, Actual := fbDut.stIo.rPT201_mA, Delta := 0.0,
                  Message := 'PT201 injection');
AssertEquals_REAL(Expected := 4.0, Actual := fbDut.stIo.rFT202_mA, Delta := R_EPS_MA, Message := 'FT202 unaffected');

coUnit.TEST_FINISHED();
