coUnit.TEST('ControlSelector_ManualModeAlwaysManual_A4');

fbDut(eMode := E_StationMode.Manual, eMethod := E_ControlMethod.LevelPid, xPowerLost := TRUE, xRestart := TRUE,
      xDryRun := TRUE, xFloatMode := TRUE, xEmergency := TRUE, xPidReady := TRUE);
AssertTrue(Condition := fbDut.eControlAct = E_ControlAct.Manual, Message := 'Manual mode: Manual');
AssertFalse(Condition := fbDut.xStepFallback, Message := 'no STEP fallback in Manual');
pRaw := ADR(eBad);
pRaw^ := 9;
fbDut(eMode := eBad, eMethod := E_ControlMethod.Stepped, xPowerLost := FALSE, xRestart := FALSE, xDryRun := FALSE,
      xFloatMode := FALSE, xEmergency := FALSE);
AssertTrue(Condition := fbDut.eControlAct = E_ControlAct.Manual, Message := 'garbage mode: Manual');

coUnit.TEST_FINISHED();
