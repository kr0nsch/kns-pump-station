// Каждое изменение любого поля ST_FaultInjection (23 поля по очереди) увеличивает udiFaultSeq на 1;
// вызов без изменений — нет; xClearFaults — ещё одно изменение.
METHOD PRIVATE FaultSeqCountsChanges
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
END_VAR
