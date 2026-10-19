coUnit.TEST('PlantModel_TimeAccelerationConsistency');

stCmdA.xInflowOverride := TRUE;
stCmdA.rInflowOverride_m3h := 100.0;
stCmdB := stCmdA;
fbA.axRun[1] := TRUE;
fbA.auiFref[1] := UI_FREF_50HZ;
fbB.axRun[1] := TRUE;
fbB.auiFref[1] := UI_FREF_50HZ;
fbA(itfTime := fbTimeA, stCfg := stCfg, stCmd := stCmdA, stFault := stFaultA);
fbB(itfTime := fbTimeB, stCfg := stCfg, stCmd := stCmdB, stFault := stFaultB);
FOR uiI := 1 TO 600 DO
    fbTimeA.Advance(tStep := T_FINE);
    fbA(itfTime := fbTimeA, stCfg := stCfg, stCmd := stCmdA, stFault := stFaultA);
END_FOR
FOR uiI := 1 TO 60 DO
    fbTimeB.Advance(tStep := T_STEP);
    fbB(itfTime := fbTimeB, stCfg := stCfg, stCmd := stCmdB, stFault := stFaultB);
END_FOR
// AssertEquals_REAL пропускает NaN: конечность проверяется отдельно
AssertTrue(Condition := PL.F_IsFinite(rIn := fbA.stSts.rLevel_m) AND PL.F_IsFinite(rIn := fbB.stSts.rLevel_m)
           AND PL.F_IsFinite(rIn := fbA.stSts.rOutflow_m3h) AND PL.F_IsFinite(rIn := fbB.stSts.rOutflow_m3h),
           Message := 'outputs finite');
AssertEquals_LREAL(Expected := fbA.stSts.lrSimTime_s, Actual := fbB.stSts.lrSimTime_s, Delta := LREAL#1.0E-6,
                   Message := 'same model time');
AssertEquals_REAL(Expected := 50.0, Actual := fbA.stSts.arFreq_Hz[1], Delta := 1.0E-3, Message := 'A at 50 Hz');
AssertEquals_REAL(Expected := 50.0, Actual := fbB.stSts.arFreq_Hz[1], Delta := 1.0E-3, Message := 'B at 50 Hz');
AssertEquals_REAL(Expected := fbA.stSts.rLevel_m, Actual := fbB.stSts.rLevel_m, Delta := 5.0E-3,
                  Message := 'levels agree within 5 mm');
AssertEquals_REAL(Expected := fbA.stSts.rOutflow_m3h, Actual := fbB.stSts.rOutflow_m3h, Delta := 0.5,
                  Message := 'outflows agree');
AssertTrue(Condition := fbA.stSts.rLevel_m < 1.2, Message := 'pump outpaces inflow');

coUnit.TEST_FINISHED();
