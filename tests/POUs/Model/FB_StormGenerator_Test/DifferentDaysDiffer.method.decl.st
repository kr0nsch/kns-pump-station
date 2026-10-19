// Ливни разных суток и разных seed различаются (сутки 0 и 1; seed и seed + 1).
METHOD PRIVATE DifferentDaysDiffer
VAR
    fbDut : FB_StormGenerator;  // проверяемый генератор
    stCfg : ST_SimCfg;          // параметры ливней по умолчанию
    fbOther : FB_StormGenerator;
    rStartDay0 : REAL;          // начало первого ливня суток 0
END_VAR
