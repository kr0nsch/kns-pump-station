// 04 §7.4, §10.1, §15, PMI-22: выбран ПИД, сухой ход по LL дольше выдержек KNS1.NORES и KNS1.STEP (10 с) —
// обе подавлены (насосы заблокированы защитой станции). Насос видит снятие блокировки в своём вызове — после
// станции: в цикле снятия сухого хода насосы ещё недоступны, ПИД не готов. Ни NORES (High: сирена, K1), ни STEP
// не мелькают: выдержка появления отсчитывается заново после снятия подавления; затем снова ПИД
METHOD PRIVATE DryRunReleaseNoNoresStepFlicker
VAR
    fbDut        : FB_StationCore;                    // ФБ под тестом
    fbTime       : PL.FB_FakeTime;                    // подменное время, старт 1 ч
    fbSink       : FB_FakeEventSink;                  // подменный журнал
    afbPump      : ARRAY[1..3] OF FB_FakeMotorVfd;    // подменные насосы: доступны, Auto, стоят
    stCmd        : ST_StationCmd;                     // GVL_Station.stStationCmd
    stCfgPersist : ST_StationCfg;                     // GVL_Persist.stStationCfg
    stCfgLkg     : ST_StationCfg;                     // GVL_Station.stCfgLkg
    stRetain     : ST_StationRetain;                  // GVL_Persist.stStationRetain
    fbPid        : PL.FB_PID;                         // GVL_Station.fbLIC101
    stPidCmd     : PL.ST_PidCmd;                      // GVL_Station.stLIC101Cmd
    stPidCfg     : PL.ST_PidCfg;                      // GVL_Persist.stLIC101Cfg
    stPidRetain  : PL.ST_DeviceRetain;                // GVL_Persist.stLIC101Retain
    fbAlarms     : FB_StationAlarms;                  // GVL_Station.fbAlarms
    itfNores     : PL.I_Alarm;                        // KNS1.NORES через интерфейс
    itfStep      : PL.I_Alarm;                        // KNS1.STEP через интерфейс
    uiIdx        : UINT;                              // насос
    uiStep       : UINT;                              // шаг
    xFlicker     : BOOL;                              // NORES или STEP были неквитированными хотя бы в одном цикле
END_VAR
