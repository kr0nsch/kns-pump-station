FOR uiStep := 1 TO uiSteps DO
    fbTime.Advance(tStep := T#100MS);
    fbDut(xEnable := TRUE, rLevel_m := rLevel_m, xLevelValid := TRUE, rPidOut_pct := rPidOut_pct, xInit := FALSE,
          itfTime := fbTime, stCfg := stCfg);
END_FOR
