coUnit.TEST('PlantModel_ButtonsPulse');

stCmd.xPressReset := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertFalse(Condition := stCmd.xPressReset, Message := 'pulse reset');
AssertTrue(Condition := fbDut.stIo.xHS501, Message := 'HS501 pressed');
AssertFalse(Condition := fbDut.stIo.xHS502, Message := 'HS502 not pressed');
FOR uiI := 1 TO 4 DO
    fbTime.Advance(tStep := T_FINE);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertTrue(Condition := fbDut.stIo.xHS501, Message := 'HS501 pressed at 0.4 s');
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_FINE);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertFalse(Condition := fbDut.stIo.xHS501, Message := 'HS501 released at 0.5 s');
stCmd.xPressSilence := TRUE;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
AssertTrue(Condition := fbDut.stIo.xHS502 AND NOT stCmd.xPressSilence, Message := 'HS502 pressed');

coUnit.TEST_FINISHED();
