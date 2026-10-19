// 04 §3.2, §7.4, §15, PMI-01, PMI-30: выбран ПИД — при старте ПЛК (LIC101 и насосы ещё не вызывались) и при
// переходе «Ручной» → «Автомат» (насосы ещё в Manual, доступных нет) готовность ПИД пару циклов ложна. Это не
// отказ: KNS1.STEP (Low) не появляется и не остаётся неквитированной (задержка появления тревоги)
METHOD PRIVATE StepAlarmNoFlickerOnStartAndAutoEntry
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
    uiIdx        : UINT;                              // насос
END_VAR
