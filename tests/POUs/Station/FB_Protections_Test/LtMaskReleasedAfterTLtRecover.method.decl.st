// 04 §10.5, §11, PMI-27: маска уровнемера снимается, когда сигнал в норме без противоречий дольше tLtRecover;
// выход из режима по поплавкам — ещё через tLtRecover годного уровня (101014)
METHOD PRIVATE LtMaskReleasedAfterTLtRecover
VAR
    fbDut  : FB_Protections;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (tLdev 30 с, tLtRecover 30 с, tDryRelease 60 с)
    fbSink : FB_FakeEventSink;          // подменный журнал
END_VAR
