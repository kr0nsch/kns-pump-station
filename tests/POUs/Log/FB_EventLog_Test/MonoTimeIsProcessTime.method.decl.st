// lrMono_s — время процесса по itfTime: разность меток двух записей равна шагу подменных часов (90 с), а не
// настенному времени между вызовами
METHOD PRIVATE MonoTimeIsProcessTime
VAR_INST
    fbLog  : FB_EventLog;           // проверяемый журнал
END_VAR
VAR
    fbTime  : PL.FB_FakeTime;       // подменное время
    stFirst : ST_EventRecord;       // первая запись
    stLast  : ST_EventRecord;       // вторая запись
END_VAR
