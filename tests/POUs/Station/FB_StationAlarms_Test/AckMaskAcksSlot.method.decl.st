// 04 §19.2: маска wAckReq, бит slot - 1, квитирует свою тревогу, остальные — нет
METHOD PRIVATE AckMaskAcksSlot
VAR
    fbDut  : FB_StationAlarms;          // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // тревоги по умолчанию (05_alarm_list.csv)
    itfAlm : PL.I_Alarm;              // тревога через интерфейс
END_VAR
