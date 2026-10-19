FOR uiStep := 1 TO uiSteps DO
    fbTime.Advance(tStep := tStep);
    // сохранённая копия LKG — та же переменная, что и действующая: перезапуск ПЛК эти тесты не моделируют
    fbDut(itfTime := fbTime, stCmd := stCmd, stCfgPersist := stCfgPersist, stCfgLkg := stCfgLkg,
          stCfgLkgRetain := stCfgLkg, stRetain := stRetain, fbLIC101 := fbPid, stLIC101Cmd := stPidCmd,
          stLIC101Cfg := stPidCfg, stLIC101Retain := stPidRetain, fbAlarms := fbAlarms);
    IF xPlant THEN
        FOR uiIdx := 1 TO 3 DO
            IF afbPump[uiIdx].eMode = PL.E_DeviceMode.Auto THEN
                afbPump[uiIdx].xRunning := fbDut.axRun[uiIdx] AND afbPump[uiIdx].xAvailable
                                           AND NOT afbPump[uiIdx].xFault;
                afbPump[uiIdx].xSpeedAuto := afbPump[uiIdx].xRunning;
                afbPump[uiIdx].rSpeedRef := SEL(afbPump[uiIdx].xRunning, 0.0, fbDut.rSpeedSp_pct);
                afbPump[uiIdx].rSpeedAct := afbPump[uiIdx].rSpeedRef;
            END_IF
        END_FOR
    END_IF
END_FOR
