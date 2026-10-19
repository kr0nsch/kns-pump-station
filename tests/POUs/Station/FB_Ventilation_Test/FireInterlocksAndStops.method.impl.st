coUnit.TEST('Ventilation_FireInterlocksAndStops_A17_PMI38');

fbDut(xGasHigh := TRUE, xFire := TRUE, itfTime := fbTime, stCfg := stCfg);
AssertFalse(Condition := fbDut.xRun, Message := 'fire: V1 stopped');
AssertEquals_WORD(Expected := GVL_Const.V1_ILK_FIRE, Actual := fbDut.wInterlock, Message := 'fire interlock bit 0');
fbDut(xGasHigh := TRUE, xFire := FALSE, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xRun AND fbDut.wInterlock = 0, Message := 'fire cleared: V1 runs');

coUnit.TEST_FINISHED();
