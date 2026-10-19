coUnit.TEST('PlantModel_StepCappedAtMax');

fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
fbTime.Advance(tStep := T#10S);
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertEquals_LREAL(Expected := 2.0, Actual := fbDut.stSts.lrSimTime_s, Delta := LREAL#1.0E-9,
                   Message := 'step capped at 2 s');

coUnit.TEST_FINISHED();
