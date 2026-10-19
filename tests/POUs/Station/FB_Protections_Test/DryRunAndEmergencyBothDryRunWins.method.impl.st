coUnit.TEST('Protections_DryRunAndEmergencyBothDryRunWins_A10');

fbDut.itfEvents := fbSink;
fbDut.rLevel_m := 1.5;
fbDut.xLevelValid := TRUE;
fbDut.eLevelNe107 := PL.E_Ne107Status.Good;
fbDut(itfTime := fbTime, stCfg := stCfg);

fbDut.xFloatDry := TRUE;
fbDut.xFloatHigh := TRUE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

AssertTrue(Condition := fbDut.xDryRun AND fbDut.xEmergency, Message := 'both conditions reported');
fbDut.xLevelValid := FALSE;
Run(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, tStep := T#100MS, uiSteps := 1);

AssertEquals_UINT(Expected := 0, Actual := fbDut.uiFloatRequired, Message := 'float mode: LS103 wins, no pumping');

coUnit.TEST_FINISHED();
