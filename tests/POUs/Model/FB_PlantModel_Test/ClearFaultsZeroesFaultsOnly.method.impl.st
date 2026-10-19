coUnit.TEST('PlantModel_ClearFaultsZeroesFaultsOnly');

stCmd.xInflowOverride := TRUE;
stCmd.rInflowOverride_m3h := 77.0;
stFault.axVfdFault[1] := TRUE;
stFault.aeAiFault[GVL_Const.SIM_AI_PT201] := E_SimAiFault.FailHigh;
stFault.rH2S_mgm3 := 12.0;
stFault.xPowerLoss := TRUE;
stFault.eLs103Stuck := E_SimFloatStuck.StuckTripped;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
stCmd.xClearFaults := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertTrue(Condition := F_FaultInjEqual(stA := stFault, stB := stNoFaults), Message := 'all injections cleared');
AssertEquals_REAL(Expected := -1.0, Actual := stFault.rH2S_mgm3, Delta := 0.0, Message := 'gas back to background');
AssertFalse(Condition := stCmd.xClearFaults, Message := 'pulse reset');
AssertTrue(Condition := stCmd.xInflowOverride, Message := 'inflow override kept');
AssertEquals_REAL(Expected := 77.0, Actual := stCmd.rInflowOverride_m3h, Delta := 0.0, Message := 'inflow value kept');
AssertEquals_REAL(Expected := 1.2, Actual := fbDut.stSts.rLevel_m, Delta := R_EPS_M, Message := 'level kept');
AssertEquals_REAL(Expected := 4.24, Actual := fbDut.stIo.rAT401_mA, Delta := R_EPS_MA, Message := 'AT401 background');

coUnit.TEST_FINISHED();
