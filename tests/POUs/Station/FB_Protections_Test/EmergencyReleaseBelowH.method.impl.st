coUnit.TEST('Protections_EmergencyReleaseBelowH_A10_PMI20');

fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.5;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.rLevel_m := 4.05;
fbDut.xLevelH := TRUE;
fbDut.xLevelHH := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

fbDut.rLevel_m := 3.8;
fbDut.xLevelHH := FALSE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 10);

AssertTrue(Condition := fbDut.xEmergency, Message := 'between H and HH: still emergency');
fbDut.xFloatHigh := TRUE;
fbDut.rLevel_m := 3.4;
fbDut.xLevelH := FALSE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

AssertTrue(Condition := fbDut.xEmergency, Message := 'LS102 still tripped: emergency');
fbDut.xFloatHigh := FALSE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

AssertFalse(Condition := fbDut.xEmergency, Message := 'LS102 released and below H: released');

coUnit.TEST_FINISHED();
