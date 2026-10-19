coUnit.TEST('PlantModel_FanNoFeedback');

fbDut.xV1Run := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
FOR uiI := 1 TO 9 DO
    fbTime.Advance(tStep := T_FINE);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertFalse(Condition := fbDut.stIo.xV1_RFB, Message := 'no feedback at 0.9 s');
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_FINE);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertTrue(Condition := fbDut.stIo.xV1_RFB, Message := 'feedback at 1.0 s');
stFault.xFanNoFeedback := TRUE;
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_FINE);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertFalse(Condition := fbDut.stIo.xV1_RFB, Message := 'feedback injection: no feedback');
stFault.xFanNoFeedback := FALSE;
stFault.xFanFault := TRUE;
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_FINE);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertTrue(Condition := fbDut.stIo.xV1_FLT AND fbDut.stIo.xV1_RFB, Message := 'fan fault contact');
fbDut.xV1Run := FALSE;
FOR uiI := 1 TO 10 DO
    fbTime.Advance(tStep := T_FINE);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertTrue(Condition := fbDut.stIo.xV1_RFB, Message := 'feedback held 0.9 s after stop');
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_FINE);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertFalse(Condition := fbDut.stIo.xV1_RFB, Message := 'feedback drops 1.0 s after stop');

coUnit.TEST_FINISHED();
