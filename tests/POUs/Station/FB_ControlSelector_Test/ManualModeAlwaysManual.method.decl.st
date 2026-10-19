// 04 §4: в «Ручном» — Manual при любых условиях (защиты действуют блокировками, без запросов); режим вне
// перечисления — как «Ручной»
METHOD PRIVATE ManualModeAlwaysManual
VAR
    fbDut : FB_ControlSelector;          // ФБ под тестом
    pRaw : POINTER TO INT;             // режим вне перечисления
    eBad  : E_StationMode;              // мусор
END_VAR
