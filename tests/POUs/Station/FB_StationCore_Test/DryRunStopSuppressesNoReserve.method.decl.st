// 04 §10.1, §11, §15, PMI-21: откачка по поплавкам до LS103 — сухой ход блокирует все насосы (Available = FALSE).
// Насосы стоят по защите станции, а не из-за отказов: KNS1.NORES подавлена (дубль KNS1.DRY, иначе High-тревога и
// обесточенное K1 в каждом цикле откачки по поплавкам)
METHOD PRIVATE DryRunStopSuppressesNoReserve
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
    itfAlm       : PL.I_Alarm;                        // тревога через интерфейс
    uiIdx        : UINT;                              // насос
END_VAR
