// 04 §10.5, PMI-26: уровнемер вне диапазона (NE 107 S) показывает LL, LS103 не сработал — сухой ход, через tLdev
// уровнемер исключён (LDEV, бит 15 wState), режим по поплавкам (101013), через tDryRelease сухой ход снят
METHOD PRIVATE OorLtContradictingFloatMaskedAfterTLdev
VAR
    fbDut  : FB_Protections;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (tLdev 30 с, tLtRecover 30 с, tDryRelease 60 с)
    fbSink : FB_FakeEventSink;          // подменный журнал
END_VAR
