// Сгенерированный порядок (ES301, затем P101): насос работает по ОС (реле «Работа» ПЧ, xFbFromComm = FALSE),
// станция подхватила его запросом (xAutoRun из GVL_IO.xP101_RFB в первом цикле) — первый вызов P101 видит
// напряжение, насос в Running с командой xQRun, пуск не засчитан; через 5 с — так же, без отказов
METHOD PRIVATE AdoptedInGeneratedOrder
VAR
    fbTime   : PL.FB_FakeTime;          // подменное время, старт 1 ч
    stDiCmd  : PL.ST_DigitalInputCmd;   // GVL_Hmi.stES301Cmd
    stDiCfg  : PL.ST_DigitalInputCfg;   // GVL_Persist.stES301Cfg
    stMotCmd : PL.ST_MotorCmd;          // GVL_Hmi.stP101Cmd
    stMotCfg : PL.ST_MotorCfg;          // GVL_Persist.stP101Cfg
    stMotRet : PL.ST_DeviceRetain;      // GVL_Persist.stP101Retain
    uiStep   : UINT;                    // шаг
END_VAR
VAR_INST
    fbES301  : PL.FB_DigitalInput;      // GVL_Devices.fbES301
    fbP101   : PL.FB_MotorVfd;          // GVL_Devices.fbP101
END_VAR
