// Параметры по умолчанию, сутки 0: два ливня — 2,7587 ч, 1 549 386 мс, 133,93 м³/ч и 4,5323 ч,
// 3 011 220 мс, 193,78 м³/ч; в 0 ч ливня нет.
METHOD PRIVATE DefaultsSeedDayZeroStorms
VAR
    fbDut : FB_StormGenerator;  // проверяемый генератор
    stCfg : ST_SimCfg;          // параметры ливней по умолчанию
END_VAR
