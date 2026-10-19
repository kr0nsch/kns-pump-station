// 04 §7.3, §9.1, §10.4, PMI-16 в режиме ПИД: перегрев обмотки ведущего (блокировка станции) при двух работающих
// насосах — устройство останавливает насос в цикле блокировки, роль передаётся в следующем; выход LIC101 и частота
// насосов не проваливаются: ПИД не следует за заданием 0 остановленного блокировкой ПЧ. Недогрузка (10.3) приходит
// через ту же блокировку станции wInterlock
METHOD PRIVATE PidLeadTripKeepsOutput
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
    rOutBefore   : REAL;                              // выход LIC101 до события
    rMinSp       : REAL;                              // наименьшее общее задание частоты после события
    uiStep       : UINT;                              // шаг после события
END_VAR
