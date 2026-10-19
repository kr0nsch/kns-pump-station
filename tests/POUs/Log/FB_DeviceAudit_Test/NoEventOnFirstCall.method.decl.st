// Первый вызов запоминает режимы устройств без событий (режимы после старта ПЛК — из retain)
METHOD PRIVATE NoEventOnFirstCall
VAR_INST
    fbLog : FB_EventLog;            // журнал
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    fbDut  : FB_DeviceAudit;        // проверяемый аудит
    fbDi   : PL.FB_DigitalInput;    // устройство
    stCmd  : PL.ST_DigitalInputCmd;
    stCfg  : PL.ST_DigitalInputCfg;
END_VAR
