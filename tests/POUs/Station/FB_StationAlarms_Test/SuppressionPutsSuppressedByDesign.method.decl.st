// 04 §15, PMI-21: подавление по условию — SuppressedByDesign без неквитированности, бит в wAlmShelved
METHOD PRIVATE SuppressionPutsSuppressedByDesign
VAR
    fbDut  : FB_StationAlarms;          // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // тревоги по умолчанию (05_alarm_list.csv)
    itfAlm : PL.I_Alarm;              // тревога через интерфейс
END_VAR
