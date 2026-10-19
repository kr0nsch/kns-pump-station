coUnit.TEST('TankModel_ShortOverflowCounted');

fbDut.SetLevel(rNewLevel_m := R_OVERFLOW_M);
fbDut(rInflow_m3h := 250.0, rOutflow_m3h := 0.0, lrDt_s := LR_SHORT_S, rArea_m2 := R_AREA_M2,
      rOverflow_m := R_OVERFLOW_M);
AssertTrue(Condition := fbDut.xOverflow, Message := 'overflow active');
AssertEquals_UDINT(Expected := 1, Actual := fbDut.udiOverflow_s, Message := 'short overflow counted');
fbDut(rInflow_m3h := 100.0, rOutflow_m3h := 150.0, lrDt_s := LR_SHORT_S, rArea_m2 := R_AREA_M2,
      rOverflow_m := R_OVERFLOW_M);
AssertFalse(Condition := fbDut.xOverflow, Message := 'overflow ended');
AssertEquals_UDINT(Expected := 1, Actual := fbDut.udiOverflow_s, Message := 'short overflow kept');

coUnit.TEST_FINISHED();
