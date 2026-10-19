// 04 §7.3, §8.2 в режиме ПИД: ведущий работает непрерывно дольше tMaxContRun — передача роли резервному с
// перекрытием tOverlap; роль переходит к уже работающей замене в том же цикле, когда прежний насос теряет запрос,
// поэтому выход LIC101 и частота насосов не проваливаются ни в одном шаге передачи
METHOD PRIVATE PidHandoverKeepsOutput
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
