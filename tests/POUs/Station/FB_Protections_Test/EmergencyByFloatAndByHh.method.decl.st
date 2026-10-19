// 04 §10.2, PMI-20, PMI-23: аварийный уровень — по LS102 и по HH годного уровнемера
METHOD PRIVATE EmergencyByFloatAndByHh
VAR
    fbDut  : FB_Protections;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (tLdev 30 с, tLtRecover 30 с, tDryRelease 60 с)
    fbSink : FB_FakeEventSink;          // подменный журнал
    fbDut2 : FB_Protections;           // второй экземпляр: HH
END_VAR
