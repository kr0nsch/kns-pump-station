coUnit.TEST('PlantModel_DefaultsInitialState');

fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertEquals_REAL(Expected := 1.2, Actual := fbDut.stSts.rLevel_m, Delta := R_EPS_M, Message := 'initial level');
AssertEquals_REAL(Expected := 7.84, Actual := fbDut.stIo.rLT101_mA, Delta := R_EPS_MA, Message := 'LT101 mA');
// ref: hydraulic.stopped.pressure_bar = 1,1772 бар
AssertEquals_REAL(Expected := 5.88352, Actual := fbDut.stIo.rPT201_mA, Delta := R_EPS_MA, Message := 'PT201 mA');
AssertEquals_REAL(Expected := 4.0, Actual := fbDut.stIo.rFT202_mA, Delta := R_EPS_MA, Message := 'FT202 mA');
AssertEquals_REAL(Expected := 4.24, Actual := fbDut.stIo.rAT401_mA, Delta := R_EPS_MA, Message := 'AT401 background');
AssertEquals_REAL(Expected := 4.24, Actual := fbDut.stIo.rAT402_mA, Delta := R_EPS_MA, Message := 'AT402 background');
AssertTrue(Condition := fbDut.stIo.xLS102 AND fbDut.stIo.xLS103 AND fbDut.stIo.xES301 AND fbDut.stIo.xTS112
           AND fbDut.stIo.xTS122 AND fbDut.stIo.xTS132, Message := 'NC contacts normal');
AssertFalse(Condition := fbDut.stIo.xYS302 OR fbDut.stIo.xP101_RFB OR fbDut.stIo.xP101_FLT OR fbDut.stIo.xHS501,
            Message := 'no alarms, pumps stopped');
AssertTrue(Condition := fbDut.stIo.xMbOk_RS485_1_S1 AND fbDut.stIo.xMbOk_RS485_1_S2 AND fbDut.stIo.xMbOk_RS485_1_S3
           AND fbDut.stIo.xMbOk_RS485_2_S10, Message := 'Modbus ok');
AssertEquals_WORD(Expected := GVL_Const.VFD_STW_READY OR GVL_Const.VFD_STW_REMOTE, Actual := fbDut.stIo.wP103_STW,
                  Message := 'drives ready');
AssertEquals_REAL(Expected := 18.0, Actual := fbDut.stIo.rTT403, Delta := 0.0, Message := 'TT403');
AssertEquals_REAL(Expected := 38.5, Actual := fbDut.stSts.rInflow_m3h, Delta := 1.0E-3, Message := 'inflow at 00:00');
AssertTrue(Condition := fbDut.stSts.xRunning, Message := 'model running');
AssertEquals_UDINT(Expected := 0, Actual := fbDut.stSts.udiFaultSeq, Message := 'no fault changes');
AssertEquals_REAL(Expected := 1.0, Actual := fbDut.stSts.rTimeScaleAct, Delta := 0.0, Message := 'time scale 1');

coUnit.TEST_FINISHED();
