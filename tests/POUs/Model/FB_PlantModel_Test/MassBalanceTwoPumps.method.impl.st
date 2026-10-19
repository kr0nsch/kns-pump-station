coUnit.TEST('PlantModel_MassBalanceTwoPumps');

stCmd.xInflowOverride := TRUE;
stCmd.rInflowOverride_m3h := 120.0;
stCmd.xSetLevel := TRUE;
stCmd.rSetLevel_m := 2.0;
fbDut.axRun[1] := TRUE;
fbDut.auiFref[1] := UI_FREF_50HZ;
fbDut.axRun[2] := TRUE;
fbDut.auiFref[2] := UI_FREF_50HZ;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
FOR uiI := 1 TO 12 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
lrLevel0_m := REAL_TO_LREAL(fbDut.stSts.rLevel_m);
lrExpected_m := lrLevel0_m;
FOR uiI := 1 TO 60 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
    lrExpected_m := lrExpected_m + REAL_TO_LREAL(fbDut.stSts.rInflow_m3h - fbDut.stSts.rOutflow_m3h)
                    * PL.F_TimeToSec(tIn := T_STEP) / REAL_TO_LREAL(GVL_Const.SIM_S_PER_H)
                    / REAL_TO_LREAL(stCfg.rTankArea_m2);
END_FOR
// AssertEquals_REAL пропускает NaN: конечность проверяется отдельно
AssertTrue(Condition := PL.F_IsFinite(rIn := fbDut.stSts.rLevel_m) AND PL.F_IsFinite(rIn := fbDut.stSts.rOutflow_m3h)
           AND PL.F_IsFinite(rIn := fbDut.stIo.rFT202_mA), Message := 'outputs finite');
AssertTrue(Condition := fbDut.stSts.rOutflow_m3h > 190.0, Message := 'two pumps deliver about 198 m3/h');
AssertEquals_REAL(Expected := fbDut.stSts.arPumpFlow_m3h[1] + fbDut.stSts.arPumpFlow_m3h[2],
                  Actual := fbDut.stSts.rOutflow_m3h, Delta := 1.0E-3, Message := 'station flow = sum of pumps');
AssertEquals_REAL(Expected := fbDut.stSts.arPumpFlow_m3h[1], Actual := fbDut.stSts.arPumpFlow_m3h[2],
                  Delta := 1.0E-3, Message := 'equal pumps share equally');
AssertEquals_LREAL(Expected := lrExpected_m, Actual := REAL_TO_LREAL(fbDut.stSts.rLevel_m), Delta := LREAL#1.0E-4,
                   Message := 'level follows reported inflow and outflow');
AssertTrue(Condition := lrLevel0_m - REAL_TO_LREAL(fbDut.stSts.rLevel_m) > LREAL#0.1, Message := 'level falls 0.1 m');
AssertEquals_REAL(Expected := PL.GVL_Const.MA_ZERO + PL.GVL_Const.MA_SPAN * fbDut.stSts.rOutflow_m3h
                              / GVL_Const.SIM_FT202_RANGE_M3H,
                  Actual := fbDut.stIo.rFT202_mA, Delta := R_EPS_MA, Message := 'FT202 shows station flow');

coUnit.TEST_FINISHED();
