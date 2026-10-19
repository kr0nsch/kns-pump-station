coUnit.TEST('PlantModel_PumpAndStationInjectionsReachIo');

fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
stFault.axVfdFault[2] := TRUE;
stFault.axOverheat[1] := TRUE;
stFault.axLeak[3] := TRUE;
stFault.axLocal[2] := TRUE;
stFault.axVfdCommLoss[3] := TRUE;
stFault.xValveChamberFlood := TRUE;
stFault.xFire := TRUE;
stFault.xUpsFault := TRUE;
stCmd.xDoorOpen := TRUE;
stFault.rH2S_mgm3 := 12.0;
stFault.rCh4_pctLel := 25.0;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertTrue(Condition := fbDut.stIo.xP102_FLT AND (fbDut.stIo.wP102_STW AND GVL_Const.VFD_STW_FAULT) <> 0,
           Message := 'P102 drive fault');
AssertEquals_UINT(Expected := GVL_Const.SIM_VFD_FCODE_EXT, Actual := fbDut.stIo.uiP102_FCODE,
                  Message := 'P102 code 11');
AssertTrue(Condition := NOT fbDut.stIo.xTS112 AND fbDut.stIo.xP101_FLT, Message := 'P101 overheat trips drive');
AssertEquals_UINT(Expected := GVL_Const.SIM_VFD_FCODE_OVERHEAT, Actual := fbDut.stIo.uiP101_FCODE,
                  Message := 'P101 code 12');
AssertTrue(Condition := fbDut.stIo.xMS133 AND fbDut.stIo.xHS124 AND NOT fbDut.stIo.xMbOk_RS485_1_S3,
           Message := 'leak, local, comm loss');
AssertTrue(Condition := fbDut.stIo.xLS203 AND fbDut.stIo.xYS405 AND fbDut.stIo.xYS303 AND fbDut.stIo.xZS404,
           Message := 'station contacts');
AssertEquals_REAL(Expected := 8.8, Actual := fbDut.stIo.rAT401_mA, Delta := R_EPS_MA, Message := 'H2S 12 mg/m3');
AssertEquals_REAL(Expected := 8.0, Actual := fbDut.stIo.rAT402_mA, Delta := R_EPS_MA, Message := 'CH4 25 % LEL');
stFault.xTempCommLoss := TRUE;
stCfg.rAirTemp_C := 30.0;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertEquals_REAL(Expected := 18.0, Actual := fbDut.stIo.rTT403, Delta := 0.0, Message := 'TT403 frozen');
AssertFalse(Condition := fbDut.stIo.xMbOk_RS485_2_S10, Message := 'RS485-2 no comm');
stFault.xTempCommLoss := FALSE;
stFault.xPowerLoss := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertEquals_REAL(Expected := 30.0, Actual := fbDut.stIo.rTT403, Delta := 0.0, Message := 'TT403 updated');
AssertTrue(Condition := NOT fbDut.stIo.xES301 AND fbDut.stIo.xYS302, Message := 'power loss contacts');
AssertFalse(Condition := fbDut.stIo.xMbOk_RS485_1_S1 OR fbDut.stIo.xMbOk_RS485_1_S2, Message := 'drives unpowered');
AssertEquals_WORD(Expected := 0, Actual := fbDut.stIo.wP101_STW, Message := 'unpowered STW 0');

coUnit.TEST_FINISHED();
