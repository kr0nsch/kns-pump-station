// PL.I_AlarmSource.AckAll (сводка, общий сброс): квитирует все тревоги станции ближайшим вызовом
METHOD PRIVATE AckAllViaInterface
VAR
    fbDut  : FB_StationAlarms;          // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // тревоги по умолчанию (05_alarm_list.csv)
    itfSrc : PL.I_AlarmSource;        // источник через интерфейс
END_VAR
