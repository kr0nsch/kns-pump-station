// Инъекции датчика LT101 (уровень 1,2 м, 7,84 мА): обрыв 0, FailLow 3,0, FailHigh 22, UnderRange 3,7,
// OverRange 20,8, Forced — заданный ток; Freeze держит ток при изменении уровня; индекс SIM_AI_PT201
// действует только на PT201.
METHOD PRIVATE AiFaultCurrents
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
END_VAR
