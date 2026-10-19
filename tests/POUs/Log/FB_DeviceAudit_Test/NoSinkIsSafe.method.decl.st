// Без журнала (itfEvents = 0) смена режима считается, но ничего не пишется и ошибок нет
METHOD PRIVATE NoSinkIsSafe
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    fbDut  : FB_DeviceAudit;        // проверяемый аудит
    fbDi   : PL.FB_DigitalInput;    // устройство
    stCmd  : PL.ST_DigitalInputCmd;
    stCfg  : PL.ST_DigitalInputCfg;
END_VAR
