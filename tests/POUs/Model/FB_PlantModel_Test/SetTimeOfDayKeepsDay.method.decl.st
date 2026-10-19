// xSetTimeOfDay 23,99 ч, через 60 с — сутки 1, 0,0067 ч; снова 8,0 ч — сутки 1 остаются, приток
// по профилю 112 м³/ч (ливни выключены).
METHOD PRIVATE SetTimeOfDayKeepsDay
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
    uiI : UINT;
END_VAR
