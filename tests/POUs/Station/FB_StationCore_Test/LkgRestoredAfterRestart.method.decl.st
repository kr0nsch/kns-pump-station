// 04 §18.3, PMI-08, PMI-35: последняя корректная копия уставок переживает перезапуск ПЛК. Корректная правка
// (задание 1,8 м) принята и сохранена в энергонезависимой копии LKG, неверная (2,5 м) осталась в записанных
// уставках; после перезапуска (новый экземпляр ядра, GVL_Station.stCfgLkg — умолчания) станция работает по
// сохранённой копии 1,8 м, а не по уставкам проекта; событие 101017 при старте не пишется
METHOD PRIVATE LkgRestoredAfterRestart
VAR
    fbTime         : PL.FB_FakeTime;                  // подменное время, старт 1 ч
    afbPump        : ARRAY[1..3] OF FB_FakeMotorVfd;  // подменные насосы: доступны, Auto, стоят
    // энергонезависимые данные (GVL_Persist): переживают перезапуск
    stCfgPersist   : ST_StationCfg;                   // GVL_Persist.stStationCfg
    stCfgLkgRetain : ST_StationCfg;                   // GVL_Persist.stStationCfgLkg
    stRetain       : ST_StationRetain;                // GVL_Persist.stStationRetain
    stPidCfg       : PL.ST_PidCfg;                    // GVL_Persist.stLIC101Cfg
    stPidRetain    : PL.ST_DeviceRetain;              // GVL_Persist.stLIC101Retain
END_VAR
VAR_INST
    // до перезапуска
    fbDutBefore    : FB_StationCore;                  // ядро до перезапуска
    fbSinkBefore   : FB_FakeEventSink;                // журнал до перезапуска
    stCmdBefore    : ST_StationCmd;                   // GVL_Station.stStationCmd
    stLkgBefore    : ST_StationCfg;                   // GVL_Station.stCfgLkg
    fbPidBefore    : PL.FB_PID;                       // GVL_Station.fbLIC101
    stPidCmdBefore : PL.ST_PidCmd;                    // GVL_Station.stLIC101Cmd
    fbAlmBefore    : FB_StationAlarms;                // GVL_Station.fbAlarms
    // после перезапуска: обычные переменные снова с умолчаниями
    fbDutAfter     : FB_StationCore;                  // ядро после перезапуска
    fbSinkAfter    : FB_FakeEventSink;                // журнал после перезапуска
    stCmdAfter     : ST_StationCmd;
    stLkgAfter     : ST_StationCfg;
    fbPidAfter     : PL.FB_PID;
    stPidCmdAfter  : PL.ST_PidCmd;
    fbAlmAfter     : FB_StationAlarms;
END_VAR
