// 04 §18.3: сохранённая копия LKG проверяется при старте как записанные уставки. Неверная копия (задание 2,6 м
// вне пределов LIC101 — например, после смены пределов задания) при неверных записанных уставках не
// применяется: станция работает по уставкам проекта, копия заменяется ими
METHOD PRIVATE RestoredInvalidLkgFallsBackToDefaults
VAR
    fbDut          : FB_StationCore;                  // ФБ под тестом (первый вызов — старт ПЛК)
    fbTime         : PL.FB_FakeTime;                  // подменное время, старт 1 ч
    fbSink         : FB_FakeEventSink;                // подменный журнал
    afbPump        : ARRAY[1..3] OF FB_FakeMotorVfd;  // подменные насосы: доступны, Auto, стоят
    stCmd          : ST_StationCmd;                   // GVL_Station.stStationCmd
    stCfgPersist   : ST_StationCfg;                   // GVL_Persist.stStationCfg
    stCfgLkg       : ST_StationCfg;                   // GVL_Station.stCfgLkg
    stCfgLkgRetain : ST_StationCfg;                   // GVL_Persist.stStationCfgLkg
    stRetain       : ST_StationRetain;                // GVL_Persist.stStationRetain
    fbPid          : PL.FB_PID;                       // GVL_Station.fbLIC101
    stPidCmd       : PL.ST_PidCmd;                    // GVL_Station.stLIC101Cmd
    stPidCfg       : PL.ST_PidCfg;                    // GVL_Persist.stLIC101Cfg
    stPidRetain    : PL.ST_DeviceRetain;              // GVL_Persist.stLIC101Retain
    fbAlarms       : FB_StationAlarms;                // GVL_Station.fbAlarms
    stDef          : ST_StationCfg;                   // уставки проекта (GVL_StationDefaults)
END_VAR
