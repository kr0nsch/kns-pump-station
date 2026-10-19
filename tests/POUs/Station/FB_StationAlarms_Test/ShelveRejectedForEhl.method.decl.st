// 04 §15, PMI-36 шаг 6: KNS1.EHL отложить нельзя (tShelveMax = 0); DRY откладывается и возвращается масками
METHOD PRIVATE ShelveRejectedForEhl
VAR
    fbDut  : FB_StationAlarms;          // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // тревоги по умолчанию (05_alarm_list.csv)
    itfAlm : PL.I_Alarm;              // тревога через интерфейс
END_VAR
