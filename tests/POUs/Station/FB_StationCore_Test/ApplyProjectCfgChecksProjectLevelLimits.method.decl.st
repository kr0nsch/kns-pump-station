// 04 §18.3, DESIGN 6.15: «Применить уставки проекта» при LT101 L, перенастроенной наладчиком (1,1 м, станция —
// останов 1,2 м). PRG_Devices восстанавливает L/H LT101 уставок проекта в том же цикле, но после станции: уставки
// по умолчанию (останов 1,00 м) проверяются по L/H проекта (0,8 / 3,5 м). В цикле команды нет ложной ошибки уставок
// (NE 107 «функциональная проверка»), действующей становится копия по умолчанию, событие 101017 — одно, со значением 0
METHOD PRIVATE ApplyProjectCfgChecksProjectLevelLimits
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
END_VAR
