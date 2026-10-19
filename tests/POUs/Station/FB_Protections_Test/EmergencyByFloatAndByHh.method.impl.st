coUnit.TEST('Protections_EmergencyByFloatAndByHh_A10_PMI20_PMI23');

fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.5;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.xFloatHigh := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

AssertTrue(Condition := fbDut.xEmergency, Message := 'LS102: emergency');
fbDut2(rLevel_m := 4.05, xLevelValid := TRUE, eLevelNe107 := PL.E_Ne107Status.Good, xLevelH := TRUE, xLevelHH := TRUE,
       itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut2.xEmergency, Message := 'LT101 HH: emergency');

coUnit.TEST_FINISHED();
