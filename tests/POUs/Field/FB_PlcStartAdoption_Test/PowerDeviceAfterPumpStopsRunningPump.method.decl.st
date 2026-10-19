// Обратный порядок (P101 раньше ES301, как по dev_no без учёта link_power): в первом вызове P101 значение
// ES301 ещё не посчитано (FALSE) — подхват сразу сменяется остановом «нет напряжения», команда снята.
// Поэтому порядок вызова — свойство сгенерированного PRG_Devices (проверяет и test_generate.py)
METHOD PRIVATE PowerDeviceAfterPumpStopsRunningPump
VAR
    fbTime   : PL.FB_FakeTime;          // подменное время, старт 1 ч
    stDiCmd  : PL.ST_DigitalInputCmd;   // GVL_Hmi.stES301Cmd
    stDiCfg  : PL.ST_DigitalInputCfg;   // GVL_Persist.stES301Cfg
    stMotCmd : PL.ST_MotorCmd;          // GVL_Hmi.stP101Cmd
    stMotCfg : PL.ST_MotorCfg;          // GVL_Persist.stP101Cfg
    stMotRet : PL.ST_DeviceRetain;      // GVL_Persist.stP101Retain
END_VAR
VAR_INST
    fbES301  : PL.FB_DigitalInput;      // GVL_Devices.fbES301
    fbP101   : PL.FB_MotorVfd;          // GVL_Devices.fbP101
END_VAR
