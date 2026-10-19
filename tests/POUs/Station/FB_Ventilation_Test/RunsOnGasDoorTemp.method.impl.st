coUnit.TEST('Ventilation_RunsOnGasDoorTemp_A17_PMI38');

fbDut(xGasHigh := TRUE, itfTime := fbTime, stCfg := stCfg);
fbDut2(xDoorOpen := TRUE, itfTime := fbTime, stCfg := stCfg);
fbDut3(xTempHigh := TRUE, itfTime := fbTime, stCfg := stCfg);
AssertTrue(Condition := fbDut.xRun AND fbDut2.xRun AND fbDut3.xRun, Message := 'gas, door, temperature: V1 runs');
AssertEquals_WORD(Expected := 0, Actual := fbDut.wInterlock, Message := 'no interlock');

coUnit.TEST_FINISHED();
