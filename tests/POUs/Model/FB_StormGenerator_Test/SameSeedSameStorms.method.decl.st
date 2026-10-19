// Два генератора с одинаковым seed дают одинаковые ливни; сутки 1 совпадают с эталоном
// (4,8018 ч, 4 034 469 мс, 209,13 м³/ч и 0,3007 ч, 5 001 626 мс, 178,02 м³/ч).
METHOD PRIVATE SameSeedSameStorms
VAR
    fbDut : FB_StormGenerator;  // проверяемый генератор
    stCfg : ST_SimCfg;          // параметры ливней по умолчанию
    fbOther : FB_StormGenerator;  // второй генератор с тем же seed
    uiK : UINT;
END_VAR
