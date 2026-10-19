// Устройство dev_no 102 из Auto в Manual: событие 101018 со значением 102 · 10 + 2 = 1022; без смены — тишина
METHOD PRIVATE AuditLogsModeChange
VAR_INST
    fbLog : FB_EventLog;            // журнал
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    fbDut  : FB_DeviceAudit;        // проверяемый аудит
    fbDi1  : PL.FB_DigitalInput;    // устройство dev_no 101 (режим не меняется)
    fbDi2  : PL.FB_DigitalInput;    // устройство dev_no 102
    stCmd1 : PL.ST_DigitalInputCmd;
    stCmd2 : PL.ST_DigitalInputCmd;
    stCfg  : PL.ST_DigitalInputCfg;
    stRec  : ST_EventRecord;        // запись журнала
END_VAR
