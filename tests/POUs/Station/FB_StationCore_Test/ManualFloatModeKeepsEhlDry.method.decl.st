// 04 §3.1, §10.2, §11, §15: станция в «Ручном», LT101 отказал. Управления по поплавкам в «Ручном» нет (насосы
// автоматика не пускает), поэтому KNS1.EHL (Critical) по LS102 и KNS1.DRY по LS103 не подавляются: подавление
// «режим по поплавкам» действует только в «Автомате», где срабатывания поплавков — штатные точки управления
METHOD PRIVATE ManualFloatModeKeepsEhlDry
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
    itfEhl       : PL.I_Alarm;                        // KNS1.EHL через интерфейс
    itfDry       : PL.I_Alarm;                        // KNS1.DRY через интерфейс
END_VAR
