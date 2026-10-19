// Помощник: способ ПИД, LIC101 в Auto, старт ПЛК; пуск ведущего 1 по уровню 1,7 м, затем уровень 2,45 м —
// подпорный 2 по уровню (04 §7.2), выход ПИД около 90 % (подменные насосы следуют общему заданию частоты без
// минимальной частоты и рампы); после пуска подпорного выдерживается tStagger, чтобы резервный мог пуститься сразу
METHOD PRIVATE StartPidTwoPumps
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
    itfEvents : I_StationEventSink;                   // подменный журнал
END_VAR
