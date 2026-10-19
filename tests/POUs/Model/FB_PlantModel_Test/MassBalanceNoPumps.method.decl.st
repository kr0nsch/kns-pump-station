// Постоянный приток 60 м³/ч без насосов 10 мин: уровень растёт на 60 · (1/6) / 12 = 0,8333 м.
METHOD PRIVATE MassBalanceNoPumps
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
    uiI : UINT;
END_VAR
