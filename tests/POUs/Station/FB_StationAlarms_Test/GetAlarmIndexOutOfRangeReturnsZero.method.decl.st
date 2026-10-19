// PL.I_AlarmSource.GetAlarm вне 0…AlarmCount - 1 — 0
METHOD PRIVATE GetAlarmIndexOutOfRangeReturnsZero
VAR
    fbDut  : FB_StationAlarms;          // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // тревоги по умолчанию (05_alarm_list.csv)
    itfAlm : PL.I_Alarm;              // тревога через интерфейс
END_VAR
