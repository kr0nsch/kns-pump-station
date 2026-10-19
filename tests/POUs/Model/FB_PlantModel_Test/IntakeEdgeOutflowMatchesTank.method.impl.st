coUnit.TEST('PlantModel_IntakeEdgeOutflowMatchesTank');

stCmd.xInflowOverride := TRUE;
stCmd.rInflowOverride_m3h := 0.0;
stCmd.xSetLevel := TRUE;
stCmd.rSetLevel_m := 0.29;
fbDut.axRun[1] := TRUE;
fbDut.auiFref[1] := UI_FREF_50HZ;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
FOR uiI := 1 TO 12 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertEquals_REAL(Expected := 50.0, Actual := fbDut.stSts.arFreq_Hz[1], Delta := 1.0E-3, Message := 'drive at 50 Hz');
stCmd.rInflowOverride_m3h := R_INFLOW_EDGE_M3H;
fbTime.Advance(tStep := T_SUBSTEP);
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
stCmd.rInflowOverride_m3h := 0.0;
fbTime.Advance(tStep := T_SUBSTEP);
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertTrue(Condition := fbDut.stSts.rLevel_m >= GVL_Const.SIM_PUMP_INTAKE_M, Message := 'REAL level at intake mark');
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.stSts.rOutflow_m3h, Delta := 0.0,
                  Message := 'tank not drained: no outflow reported');
AssertEquals_REAL(Expected := 4.0, Actual := fbDut.stIo.rFT202_mA, Delta := R_EPS_MA, Message := 'FT202 zero flow');
stCmd.xSetLevel := TRUE;
stCmd.rSetLevel_m := 1.0;
fbTime.Advance(tStep := T_SUBSTEP);
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertTrue(Condition := fbDut.stSts.rOutflow_m3h > 100.0, Message := 'pumping at 1.0 m');
AssertTrue(Condition := fbDut.stSts.rLevel_m < 1.0, Message := 'level falls at 1.0 m');
stCmd.xSetLevel := TRUE;
stCmd.rSetLevel_m := 0.25;
fbTime.Advance(tStep := T_SUBSTEP);
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertEquals_REAL(Expected := 0.0, Actual := fbDut.stSts.rOutflow_m3h, Delta := 0.0,
                  Message := 'set below intake: no outflow in the same call');
AssertEquals_REAL(Expected := 0.25, Actual := fbDut.stSts.rLevel_m, Delta := R_EPS_M, Message := 'level kept 0.25 m');

coUnit.TEST_FINISHED();
