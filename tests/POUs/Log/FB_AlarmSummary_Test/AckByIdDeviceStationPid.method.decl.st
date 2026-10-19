// Квитирование по номеру у источников с номерами устройства (110), станции (100005) и LIC101 (100100);
// чужой номер и повторное квитирование — FALSE
METHOD PRIVATE AckByIdDeviceStationPid
VAR_INST
    fbDut  : FB_AlarmSummary;       // проверяемая сводка
    stView : ST_AlarmView;          // список тревог
    fbDev  : FB_TestAlarmSource;    // «устройство»: тревоги 110, 111
    fbStn  : FB_TestAlarmSource;    // «станция»: тревога 100005
    fbPid  : FB_TestAlarmSource;    // «LIC101»: тревога 100100
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    itfAlm : PL.I_Alarm;            // проверяемая тревога источника
END_VAR
