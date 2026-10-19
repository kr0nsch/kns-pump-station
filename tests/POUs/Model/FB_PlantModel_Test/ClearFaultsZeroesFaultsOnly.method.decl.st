// xClearFaults снимает все инъекции (значения по умолчанию типа: газы < 0 — фон) и сбрасывает импульс;
// приток, уровень и параметры не меняются.
METHOD PRIVATE ClearFaultsZeroesFaultsOnly
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
    stNoFaults : ST_FaultInjection;  // значения по умолчанию
END_VAR
