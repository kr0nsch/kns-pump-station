FOR uiStep := 1 TO uiSteps DO
    fbTime.Advance(tStep := tStep);
    fbDut(uiRequired := uiRequired, itfTime := fbTime, stCfg := stCfg, stRetain := stRetain);
    IF xPlant THEN
        FOR uiIdx := 1 TO 3 DO
            IF afbPump[uiIdx].eMode = PL.E_DeviceMode.Auto THEN
                afbPump[uiIdx].xRunning := fbDut.axRun[uiIdx] AND afbPump[uiIdx].xAvailable
                                           AND NOT afbPump[uiIdx].xFault;
            END_IF
        END_FOR
    END_IF
END_FOR
