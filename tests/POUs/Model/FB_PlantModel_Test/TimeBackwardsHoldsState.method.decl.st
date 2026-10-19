// «Время назад»: шаг 0 — уровень и время модели не меняются; дальше модель продолжает.
METHOD PRIVATE TimeBackwardsHoldsState
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
    uiI : UINT;
    rLevel : REAL;             // уровень до скачка времени
END_VAR
