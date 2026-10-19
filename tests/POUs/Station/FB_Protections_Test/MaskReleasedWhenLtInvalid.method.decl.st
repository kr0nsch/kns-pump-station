// 04 §10.5: маска поплавка снимается сразу, когда уровнемер стал негоден: поплавок снова защищает (сухой ход)
METHOD PRIVATE MaskReleasedWhenLtInvalid
VAR
    fbDut  : FB_Protections;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (tLdev 30 с, tLtRecover 30 с, tDryRelease 60 с)
    fbSink : FB_FakeEventSink;          // подменный журнал
END_VAR
