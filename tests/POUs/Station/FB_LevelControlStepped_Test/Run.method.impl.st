FOR uiStep := 1 TO uiSteps DO
    fbTime.Advance(tStep := T#100MS);
    fbDut(xEnable := TRUE, rLevel_m := rLevel_m, xLevelValid := xValid, xInit := FALSE, itfTime := fbTime,
          stCfg := stCfg);
END_FOR
