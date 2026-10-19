coUnit.TEST('Protections_OorLtInvalidFloatsAtOnce_A10_A11_PMI26');

stAiCfg := GVL_CfgProject.stLT101Cfg;
fbDut.itfEvents := fbSink;
// 12 мА — 1,5 м, поплавки не сработали
RunWithAi(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, fbAi := fbLT101, stAiCmd := stAiCmd, stAiCfg := stAiCfg,
          rIn_mA := 12.0, uiSteps := 100);
AssertTrue(Condition := fbLT101.xValid AND fbDut.xLevelUsable, Message := '12 mA: level usable');
AssertFalse(Condition := fbDut.xFloatMode, Message := '12 mA: no float mode');

// 3,7 мА: до подтверждения выхода за диапазон значение годно
RunWithAi(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, fbAi := fbLT101, stAiCmd := stAiCmd, stAiCfg := stAiCfg,
          rIn_mA := 3.7, uiSteps := 15);
AssertTrue(Condition := fbLT101.xValid AND fbDut.xLevelUsable, Message := '1.5 s: not confirmed, still usable');
AssertFalse(Condition := fbDut.xDryRun OR fbDut.xFloatMode, Message := '1.5 s: no dry run, no float mode');
RunWithAi(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, fbAi := fbLT101, stAiCmd := stAiCmd, stAiCfg := stAiCfg,
          rIn_mA := 3.7, uiSteps := 10);
AssertFalse(Condition := fbLT101.xValid, Message := '2.5 s: confirmed out of range, xValid FALSE (AI-13)');
AssertTrue(Condition := fbLT101.stSts.stCommon.eNe107 = PL.E_Ne107Status.OutOfSpecification,
           Message := 'NE 107 out of specification');
AssertTrue(Condition := fbDut.xFloatMode AND NOT fbDut.xLevelUsable, Message := 'float mode at once');
AssertTrue(Condition := fbSink.Has(eFind := E_StationEvent.FloatModeOn), Message := 'event 101013');

// 40 с: LS103 не сработал, уровнемер показывает насыщение (LL уровнемера)
RunWithAi(fbDut := fbDut, fbTime := fbTime, stCfg := stCfg, fbAi := fbLT101, stAiCmd := stAiCmd, stAiCfg := stAiCfg,
          rIn_mA := 3.7, uiSteps := 400);
AssertTrue(Condition := fbLT101.xLL, Message := 'limits evaluated on the saturated value: LL');
AssertFalse(Condition := fbDut.xDryRun, Message := 'no dry run by an invalid level');
AssertFalse(Condition := fbDut.xLdev, Message := 'no contradiction with an invalid level');
AssertEquals_WORD(Expected := 0, Actual := fbDut.wLdev, Message := 'no LDEV bits');
AssertTrue(Condition := fbDut.xFloatMode, Message := 'still in float mode');

coUnit.TEST_FINISHED();
