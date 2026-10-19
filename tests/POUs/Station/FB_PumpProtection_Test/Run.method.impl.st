FOR uiStep := 1 TO uiSteps DO
    fbTime.Advance(tStep := T#1S);
    fbDut(xReset := FALSE, itfTime := fbTime, stCfg := stCfg);
END_FOR
