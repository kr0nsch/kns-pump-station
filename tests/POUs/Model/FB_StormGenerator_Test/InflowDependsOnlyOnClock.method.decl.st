// Приток зависит только от часов модели: 50 мелких шагов 4,5 → 5,0 ч и один вызов в 5,0 ч дают
// одинаковое значение (ливни одинаковы при любом ускорении); часы назад — значение как у нового
// генератора в том же моменте.
METHOD PRIVATE InflowDependsOnlyOnClock
VAR
    fbDut : FB_StormGenerator;  // проверяемый генератор
    stCfg : ST_SimCfg;          // параметры ливней по умолчанию
    fbOther : FB_StormGenerator;
    fbFresh : FB_StormGenerator;  // генератор, впервые вызванный в 4,6 ч
    uiK : UINT;
END_VAR
