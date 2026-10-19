// В1: блок-контакт следует команде через 1 с (0,9 с — нет, 1,0 с — есть); xFanNoFeedback — ОС нет при
// поданной команде (V1.FTS, V1.FBL); xFanFault — V1_FLT; снятие команды — ОС пропадает через 1 с.
METHOD PRIVATE FanNoFeedback
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
    uiI : UINT;
END_VAR
