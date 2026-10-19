// Один насос на 87 % (43,5 Гц), приток 120 м³/ч, уровень равновесия 1,23735 м (эталон): за 10 мин
// уровень не уходит, подача 120 м³/ч, PT201 6,9232 мА (1,8270 бар), FT202 7,84 мА, ток 19,29 А (193).
METHOD PRIVATE SteadyStateOnePump87
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
    uiI : UINT;
END_VAR
