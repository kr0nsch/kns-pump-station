// dev_no 9999 (предел контракта, API 20.1): значение события 101018 = 9999 · 10 + 2 = 99992 без переполнения
// UINT (65535)
METHOD PRIVATE LargeDevNoValueNoOverflow
VAR_INST
    fbLog : FB_EventLog;            // журнал
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    fbDut  : FB_DeviceAudit;        // проверяемый аудит
    fbDi   : PL.FB_DigitalInput;    // устройство dev_no 9999
    stCmd  : PL.ST_DigitalInputCmd;
    stCfg  : PL.ST_DigitalInputCfg;
    stRec  : ST_EventRecord;        // запись журнала
END_VAR
