// Шаг часов 10 с за вызов (пауза задачи) обрезается до SIM_DT_MAX = 2 с времени модели.
METHOD PRIVATE StepCappedAtMax
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
END_VAR
