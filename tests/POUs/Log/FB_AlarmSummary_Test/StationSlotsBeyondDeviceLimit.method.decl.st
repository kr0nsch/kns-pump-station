// PMI-01, PMI-30: у станции 13 тревог (slot 1…13), у устройства библиотеки — до восьми. Сводка видит все слоты
// источника: KNS1.SIM (slot 13) и KNS1.NOAUTO (slot 9) попадают в счётчики, в список тревог и квитируются по номеру
METHOD PRIVATE StationSlotsBeyondDeviceLimit
VAR_INST
    fbDut  : FB_AlarmSummary;       // проверяемая сводка
    stView : ST_AlarmView;          // список тревог
    fbStn  : FB_StationAlarms;      // настоящий источник станции: 13 тревог
    stCfg  : ST_StationCfg;         // тревоги станции по умолчанию (05_alarm_list.csv)
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    itfAlm : PL.I_Alarm;            // проверяемая тревога источника
END_VAR
