// 04 §7.4, §12, §13, §15, PMI-33, PMI-34: выбран ПИД, пропадание напряжения 30 с, восстановление. Пока нет
// напряжения, насосы недоступны и без связи (ПЧ без питания); после восстановления ПЧ ещё 2 с загружаются (связи
// нет). Последовательный пуск — штатный переходный режим: KNS1.STEP подавлена, загрузка ПЧ — не потеря связи
// (VFD-12), выдержка STN_PID_RECOVER не перезапускается. После последовательного пуска — сразу ПИД, STEP нет
METHOD PRIVATE StepAlarmNoFlickerAfterPowerRestorePid
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
    itfStep      : PL.I_Alarm;                        // KNS1.STEP через интерфейс
    uiIdx        : UINT;                              // насос
    uiStep       : UINT;                              // шаг
    xFlicker     : BOOL;                              // STEP была неквитированной хотя бы в одном цикле
END_VAR
