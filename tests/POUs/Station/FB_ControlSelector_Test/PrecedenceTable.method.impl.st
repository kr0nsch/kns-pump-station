coUnit.TEST('ControlSelector_PrecedenceTable_A4');

FOR uiMask := 0 TO 31 DO
    fbDut(eMode := E_StationMode.Auto, eMethod := E_ControlMethod.LevelPid, xPowerLost := (uiMask AND 1) <> 0,
          xRestart := (uiMask AND 2) <> 0, xDryRun := (uiMask AND 4) <> 0, xFloatMode := (uiMask AND 8) <> 0,
          xEmergency := (uiMask AND 16) <> 0, xPidReady := TRUE);
    IF (uiMask AND 1) <> 0 THEN
        eExpect := E_ControlAct.PowerLost;
    ELSIF (uiMask AND 2) <> 0 THEN
        eExpect := E_ControlAct.Restart;
    ELSIF (uiMask AND 4) <> 0 THEN
        eExpect := E_ControlAct.DryRunStop;
    ELSIF (uiMask AND 8) <> 0 THEN
        eExpect := E_ControlAct.Float;
    ELSIF (uiMask AND 16) <> 0 THEN
        eExpect := E_ControlAct.Emergency;
    ELSE
        eExpect := E_ControlAct.LevelPid;
    END_IF
    IF fbDut.eControlAct <> eExpect AND xAllOk THEN
        xAllOk := FALSE;
        uiBad := uiMask;
    END_IF
END_FOR
AssertTrue(Condition := xAllOk, Message := 'precedence: higher condition always wins');
AssertEquals_UINT(Expected := 0, Actual := uiBad, Message := 'first wrong combination');
fbDut(eMode := E_StationMode.Auto, eMethod := E_ControlMethod.Stepped, xPowerLost := FALSE, xRestart := FALSE,
      xDryRun := FALSE, xFloatMode := FALSE, xEmergency := FALSE, xPidReady := TRUE);
AssertTrue(Condition := fbDut.eControlAct = E_ControlAct.Stepped, Message := 'nothing active, Stepped selected');

coUnit.TEST_FINISHED();
