coUnit.TEST('PlantModel_ResetPlantRestoresLevelAndDrives');

fbDut.axRun[1] := TRUE;
fbDut.auiFref[1] := UI_FREF_50HZ;
fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
FOR uiI := 1 TO 3 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
stCmd.xSetLevel := TRUE;
stCmd.rSetLevel_m := 3.0;
stFault.axVfdFault[1] := TRUE;
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertTrue(Condition := fbDut.stIo.xP101_FLT, Message := 'drive faulted');
AssertEquals_REAL(Expected := 3.0, Actual := fbDut.stSts.rLevel_m, Delta := 0.01, Message := 'level 3 m');
stCmd.xClearFaults := TRUE;
stCmd.xResetPlant := TRUE;
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertFalse(Condition := stCmd.xResetPlant OR stCmd.xClearFaults, Message := 'pulses reset');
AssertEquals_REAL(Expected := 1.2, Actual := fbDut.stSts.rLevel_m, Delta := 0.01, Message := 'level back to 1.2 m');
AssertFalse(Condition := fbDut.stIo.xP101_FLT, Message := 'drive fault cleared');
AssertTrue(Condition := (fbDut.stIo.wP101_STW AND GVL_Const.VFD_STW_READY) <> 0, Message := 'drive ready');
FOR uiI := 1 TO 1 DO
    fbTime.Advance(tStep := T_STEP);
    fbDut(itfTime := fbTime, stCfg := stCfg, stCmd := stCmd, stFault := stFault);
END_FOR
AssertTrue(Condition := fbDut.stSts.arFreq_Hz[1] > 0.0, Message := 'wired run restarts the pump');

coUnit.TEST_FINISHED();
