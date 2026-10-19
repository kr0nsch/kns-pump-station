FOR uiStep := 1 TO uiSteps DO
    fbTime.Advance(tStep := tStep);
    fbDut(itfTime := fbTime, stCfg := stCfg);
END_FOR
