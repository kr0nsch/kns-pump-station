// Помощник: uiSteps шагов времени tStep с вызовом ядра станции и всеми данными GVL_Station и
// GVL_Persist. xPlant — подменные насосы в Auto следуют запросам и общему заданию частоты
// (видно со следующего шага): работают, если запрошены, доступны и без отказа
METHOD PRIVATE Cycle
VAR_IN_OUT
    fbDut        : FB_StationCore;                    // ФБ под тестом
    fbTime       : PL.FB_FakeTime;                    // подменное время
    stCmd        : ST_StationCmd;                     // команды
    stCfgPersist : ST_StationCfg;                     // записанные уставки
    stCfgLkg     : ST_StationCfg;                     // действующая копия
    stRetain     : ST_StationRetain;                  // режим, способ
    fbPid        : PL.FB_PID;                         // LIC101
    stPidCmd     : PL.ST_PidCmd;                      // команды LIC101
    stPidCfg     : PL.ST_PidCfg;                      // уставки LIC101
    stPidRetain  : PL.ST_DeviceRetain;                // режим LIC101
    fbAlarms     : FB_StationAlarms;                  // тревоги станции
    afbPump      : ARRAY[1..3] OF FB_FakeMotorVfd;    // подменные насосы
END_VAR
VAR_INPUT
    tStep   : TIME;                                   // шаг времени
    uiSteps : UINT;                                   // шагов
    xPlant  : BOOL;                                   // насосы следуют запросам
END_VAR
VAR
    uiStep : UINT;                                    // номер шага
    uiIdx  : UINT;                                    // насос
END_VAR
