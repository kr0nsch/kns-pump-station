// 04 §3.2, §15, PMI-30: «Ручной» дольше выдержки KNS1.NORES (10 с) при остановленных насосах, затем «Автомат».
// Насос выполняет запрос режима в своём вызове — после станции: в цикле входа в «Автомат» насосы ещё в Manual
// (доступных нет), подавление «Ручной» уже снято, а требуемое число 0 (KNS1.LACK нет). Тревога не мелькает
// (High: сирена, K1): выдержка появления отсчитывается заново после снятия подавления
METHOD PRIVATE ManualToAutoStoppedPumpsNoNoresFlicker
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
    itfAlm       : PL.I_Alarm;                        // KNS1.NORES через интерфейс
    uiIdx        : UINT;                              // насос
    uiStep       : UINT;                              // шаг
    xFlicker     : BOOL;                              // NORES была неквитированной хотя бы в одном цикле
END_VAR
